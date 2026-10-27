import 'package:flutter/material.dart';

import 'data/product_repository.dart';
import 'data/sales_repository.dart';
import 'models/product.dart';
import 'pos/pos_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.store});

  final ProductStore? store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Business App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: ProductCataloguePage(store: store ?? ProductRepository.instance),
    );
  }
}

class ProductCataloguePage extends StatefulWidget {
  const ProductCataloguePage({super.key, required this.store});

  final ProductStore store;

  @override
  State<ProductCataloguePage> createState() => _ProductCataloguePageState();
}

class _ProductCataloguePageState extends State<ProductCataloguePage> {
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refresh);
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await widget.store.getProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _loading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load products. Please try again.';
      });
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<Product> get _visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _products;
    return _products
        .where((product) => product.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  Future<void> _openProductForm({Product? product}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final formKey = GlobalKey<FormState>();
        var name = product?.name ?? '';
        var priceText =
            product == null ? '' : product.price.toStringAsFixed(2);
        var stockText = product?.stockQuantity.toString() ?? '0';

        return AlertDialog(
          title: Text(product == null ? 'Add product' : 'Edit product'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: const Key('product-name'),
                    initialValue: name,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Product name'),
                    onChanged: (value) => name = value,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a product name.'
                        : null,
                  ),
                  TextFormField(
                    key: const Key('product-price'),
                    initialValue: priceText,
                    decoration: const InputDecoration(
                      labelText: 'Selling price (PHP)',
                      prefixText: '₱ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => priceText = value,
                    validator: (value) {
                      final amount = double.tryParse(value?.trim() ?? '');
                      if (amount == null || !amount.isFinite || amount <= 0) {
                        return 'Enter a price greater than zero.';
                      }
                      if (amount > 999999999) return 'Price is too large.';
                      return null;
                    },
                  ),
                  TextFormField(
                    key: const Key('product-stock'),
                    initialValue: stockText,
                    decoration: const InputDecoration(
                      labelText: 'Initial stock quantity',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => stockText = value,
                    validator: (value) {
                      final quantity = int.tryParse(value?.trim() ?? '');
                      if (quantity == null || quantity < 0 || quantity > 999999) {
                        return 'Enter a whole quantity from 0 to 999999.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('save-product'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final amount = double.parse(priceText.trim());
                final item = Product(
                  id: product?.id,
                  name: name.trim(),
                  priceCents: (amount * 100).round(),
                  stockQuantity: int.parse(stockText.trim()),
                  isActive: product?.isActive ?? true,
                );
                try {
                  await widget.store.saveProduct(item);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                } catch (_) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Could not save product.')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      await _loadProducts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(product == null ? 'Product added.' : 'Product updated.'),
        ),
      );
    }
  }

  Future<void> _deactivate(Product product) async {
    if (product.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deactivate product?'),
        content: Text(
          '${product.name} will be hidden from the active catalogue. '
          'Its record will be retained.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep active'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.store.deactivateProduct(product.id!);
      await _loadProducts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deactivated.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not deactivate product.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _visibleProducts;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Business App'),
        actions: [
          IconButton(
            key: const Key('open-pos'),
            tooltip: 'Open POS checkout',
            icon: const Icon(Icons.point_of_sale),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PosPage(
                  products: widget.store,
                  sales: SaleRepository(),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              key: const Key('product-search'),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: _searchController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadError!),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () {
                          setState(() => _loading = true);
                          _loadProducts();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : products.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 56),
                            const SizedBox(height: 12),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No products yet'
                                  : 'No matching products',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Add your first product to start building the catalogue.'
                                  : 'Try a different product name.',
                              textAlign: TextAlign.center,
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () => _openProductForm(),
                                icon: const Icon(Icons.add),
                                label: const Text('Add product'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                        itemCount: products.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(product.name.characters.first.toUpperCase()),
                            ),
                            title: Text(product.name),
                            subtitle: Text('Stock: ${product.stockQuantity}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₱${product.price.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                PopupMenuButton<String>(
                                  tooltip: 'Product actions',
                                  onSelected: (action) {
                                    if (action == 'edit') {
                                      _openProductForm(product: product);
                                    } else if (action == 'deactivate') {
                                      _deactivate(product);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'deactivate',
                                      child: Text('Deactivate'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-product-button'),
        onPressed: () => _openProductForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
    );
  }
}
