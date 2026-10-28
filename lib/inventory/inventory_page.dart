import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/product_repository.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';
import '../utils/number_format.dart';

class _GroupedIntegerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(',', '');
    if (raw.isNotEmpty && !RegExp(r'^\\d+
  const InventoryPage({super.key, required this.repository});

  final ProductRepository repository;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Product> _products = [];
  List<StockMovement> _movements = [];
  int? _selectedProductId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final products = await widget.repository.getProducts();
      var selectedId = _selectedProductId;
      if (selectedId == null && products.isNotEmpty) {
        selectedId = products.first.id;
      }
      if (selectedId != null && !products.any((product) => product.id == selectedId)) {
        selectedId = products.isEmpty ? null : products.first.id;
      }
      final movements = await widget.repository.getStockMovements(
        productId: selectedId,
      );
      if (!mounted) return;
      setState(() {
        _products = products;
        _movements = movements;
        _selectedProductId = selectedId;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load inventory. Please try again.';
      });
    }
  }

  Future<void> _changeStock({required bool stockIn}) async {
    final id = _selectedProductId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a product first.')),
      );
      return;
    }
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(stockIn ? 'Stock in' : 'Stock out'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('inventory-movement-quantity'),
                controller: quantityController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [_GroupedIntegerInputFormatter()],
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: (value) {
                  final quantity = parseCommaSeparatedInt(value ?? '');
                  if (quantity == null || quantity < 1 || quantity > 999999) {
                    return 'Enter a whole quantity from 1 to 999999.';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: const Key('inventory-movement-reason'),
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason (required)'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a reason.'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Record movement'),
          ),
        ],
      ),
    );
    if (result != true) {
      quantityController.dispose();
      reasonController.dispose();
      return;
    }
    try {
      await widget.repository.changeStock(
        productId: id,
        quantity: parseCommaSeparatedInt(quantityController.text)!,
        stockIn: stockIn,
        reason: reasonController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(stockIn ? 'Stock added.' : 'Stock removed.')),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    } finally {
      quantityController.dispose();
      reasonController.dispose();
    }
  }

  Future<void> _adjustStock() async {
    final id = _selectedProductId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a product first.')),
      );
      return;
    }
    Product? product;
    for (final item in _products) {
      if (item.id == id) { product = item; break; }
    }
    if (product == null) return;
    final selectedProduct = product;
    final quantityController = TextEditingController(text: formatIntWithCommas(selectedProduct.stockQuantity));
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Adjust stock'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current quantity: ${formatIntWithCommas(selectedProduct.stockQuantity)}'),
              TextFormField(
                key: const Key('inventory-adjust-quantity'),
                controller: quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [_GroupedIntegerInputFormatter()],
                decoration: const InputDecoration(labelText: 'Counted quantity'),
                validator: (value) {
                  final quantity = parseCommaSeparatedInt(value ?? '');
                  if (quantity == null || quantity < 0 || quantity > 999999) {
                    return 'Enter a whole quantity from 0 to 999999.';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: const Key('inventory-adjust-reason'),
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason (required)'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a reason.'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Save adjustment'),
          ),
        ],
      ),
    );
    if (result != true) {
      quantityController.dispose();
      reasonController.dispose();
      return;
    }
    try {
      await widget.repository.adjustStock(
        productId: id,
        targetQuantity: parseCommaSeparatedInt(quantityController.text)!,
        reason: reasonController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock adjustment recorded.')),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    } finally {
      quantityController.dispose();
      reasonController.dispose();
    }
  }

  String _movementLabel(StockMovement movement) {
    switch (movement.movementType) {
      case 'stock_in':
        return 'Stock in';
      case 'stock_out':
        return 'Stock out';
      case 'adjustment':
        return 'Adjustment';
      case 'sale':
        return 'Sale';
      default:
        return movement.movementType;
    }
  }

  @override
  Widget build(BuildContext context) {
    Product? selectedProduct;
    for (final item in _products) {
      if (item.id == _selectedProductId) { selectedProduct = item; break; }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory & Movement History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 8),
                      FilledButton(onPressed: () { setState(() => _loading = true); _load(); }, child: const Text('Retry')),
                    ],
                  ),
                )
              : _products.isEmpty
                  ? const Center(child: Text('Add a product before managing inventory.'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          DropdownButtonFormField<int>(
                            key: const Key('inventory-product-picker'),
                            value: _selectedProductId,
                            decoration: const InputDecoration(labelText: 'Product'),
                            items: _products.map((product) => DropdownMenuItem<int>(
                              value: product.id,
                              child: Text(product.name, overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (value) async {
                              setState(() { _selectedProductId = value; _loading = true; });
                              await _load();
                            },
                          ),
                          if (selectedProduct != null) ...[
                            const SizedBox(height: 8),
                            Card(
                              child: ListTile(
                                title: Text(selectedProduct.name),
                                subtitle: Text('Available stock: ${formatIntWithCommas(selectedProduct.stockQuantity)}'),
                                trailing: const Icon(Icons.inventory_2_outlined),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.icon(
                                key: const Key('inventory-stock-in'),
                                onPressed: () => _changeStock(stockIn: true),
                                icon: const Icon(Icons.add),
                                label: const Text('Stock in'),
                              ),
                              OutlinedButton.icon(
                                key: const Key('inventory-stock-out'),
                                onPressed: () => _changeStock(stockIn: false),
                                icon: const Icon(Icons.remove),
                                label: const Text('Stock out'),
                              ),
                              OutlinedButton.icon(
                                key: const Key('inventory-adjust'),
                                onPressed: _adjustStock,
                                icon: const Icon(Icons.tune),
                                label: const Text('Adjust'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text('Movement history', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          if (_movements.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: Text('No stock movements recorded yet.')),
                            )
                          else
                            ..._movements.map((movement) => Card(
                              child: ListTile(
                                leading: Icon(
                                  movement.quantityDelta > 0 ? Icons.trending_up :
                                      movement.movementType == 'sale' ? Icons.point_of_sale : Icons.trending_down,
                                ),
                                title: Text('${_movementLabel(movement)} · ${movement.quantityDelta > 0 ? '+' : ''}${formatIntWithCommas(movement.quantityDelta)}'),
                                subtitle: Text('${movement.reason}\nBalance after: ${formatIntWithCommas(movement.quantityAfter)} · ${movement.createdAt.toLocal()}'),
                                isThreeLine: true,
                              ),
                            )),
                        ],
                      ),
                    ),
    );
  }
}
).hasMatch(raw)) {
      return oldValue;
    }

    final digitsBeforeCursor = newValue.text
        .substring(0, newValue.selection.extentOffset.clamp(0, newValue.text.length))
        .replaceAll(',', '')
        .length;
    final digits = raw;
    final grouped = digits.isEmpty
        ? ''
        : formatIntWithCommas(int.parse(digits));

    var cursor = 0;
    var seenDigits = 0;
    while (cursor < grouped.length && seenDigits < digitsBeforeCursor) {
      if (grouped[cursor] != ',') seenDigits++;
      cursor++;
    }
    while (cursor < grouped.length && grouped[cursor] == ',') {
      cursor++;
    }

    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key, required this.repository});

  final ProductRepository repository;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Product> _products = [];
  List<StockMovement> _movements = [];
  int? _selectedProductId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final products = await widget.repository.getProducts();
      var selectedId = _selectedProductId;
      if (selectedId == null && products.isNotEmpty) {
        selectedId = products.first.id;
      }
      if (selectedId != null && !products.any((product) => product.id == selectedId)) {
        selectedId = products.isEmpty ? null : products.first.id;
      }
      final movements = await widget.repository.getStockMovements(
        productId: selectedId,
      );
      if (!mounted) return;
      setState(() {
        _products = products;
        _movements = movements;
        _selectedProductId = selectedId;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load inventory. Please try again.';
      });
    }
  }

  Future<void> _changeStock({required bool stockIn}) async {
    final id = _selectedProductId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a product first.')),
      );
      return;
    }
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(stockIn ? 'Stock in' : 'Stock out'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('inventory-movement-quantity'),
                controller: quantityController,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: (value) {
                  final quantity = parseCommaSeparatedInt(value ?? '');
                  if (quantity == null || quantity < 1 || quantity > 999999) {
                    return 'Enter a whole quantity from 1 to 999999.';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: const Key('inventory-movement-reason'),
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason (required)'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a reason.'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Record movement'),
          ),
        ],
      ),
    );
    if (result != true) {
      quantityController.dispose();
      reasonController.dispose();
      return;
    }
    try {
      await widget.repository.changeStock(
        productId: id,
        quantity: parseCommaSeparatedInt(quantityController.text)!,
        stockIn: stockIn,
        reason: reasonController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(stockIn ? 'Stock added.' : 'Stock removed.')),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    } finally {
      quantityController.dispose();
      reasonController.dispose();
    }
  }

  Future<void> _adjustStock() async {
    final id = _selectedProductId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a product first.')),
      );
      return;
    }
    Product? product;
    for (final item in _products) {
      if (item.id == id) { product = item; break; }
    }
    if (product == null) return;
    final selectedProduct = product;
    final quantityController = TextEditingController(text: formatIntWithCommas(selectedProduct.stockQuantity));
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Adjust stock'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current quantity: ${formatIntWithCommas(selectedProduct.stockQuantity)}'),
              TextFormField(
                key: const Key('inventory-adjust-quantity'),
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Counted quantity'),
                validator: (value) {
                  final quantity = parseCommaSeparatedInt(value ?? '');
                  if (quantity == null || quantity < 0 || quantity > 999999) {
                    return 'Enter a whole quantity from 0 to 999999.';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: const Key('inventory-adjust-reason'),
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason (required)'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a reason.'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Save adjustment'),
          ),
        ],
      ),
    );
    if (result != true) {
      quantityController.dispose();
      reasonController.dispose();
      return;
    }
    try {
      await widget.repository.adjustStock(
        productId: id,
        targetQuantity: parseCommaSeparatedInt(quantityController.text)!,
        reason: reasonController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock adjustment recorded.')),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    } finally {
      quantityController.dispose();
      reasonController.dispose();
    }
  }

  String _movementLabel(StockMovement movement) {
    switch (movement.movementType) {
      case 'stock_in':
        return 'Stock in';
      case 'stock_out':
        return 'Stock out';
      case 'adjustment':
        return 'Adjustment';
      case 'sale':
        return 'Sale';
      default:
        return movement.movementType;
    }
  }

  @override
  Widget build(BuildContext context) {
    Product? selectedProduct;
    for (final item in _products) {
      if (item.id == _selectedProductId) { selectedProduct = item; break; }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory & Movement History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 8),
                      FilledButton(onPressed: () { setState(() => _loading = true); _load(); }, child: const Text('Retry')),
                    ],
                  ),
                )
              : _products.isEmpty
                  ? const Center(child: Text('Add a product before managing inventory.'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          DropdownButtonFormField<int>(
                            key: const Key('inventory-product-picker'),
                            value: _selectedProductId,
                            decoration: const InputDecoration(labelText: 'Product'),
                            items: _products.map((product) => DropdownMenuItem<int>(
                              value: product.id,
                              child: Text(product.name, overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (value) async {
                              setState(() { _selectedProductId = value; _loading = true; });
                              await _load();
                            },
                          ),
                          if (selectedProduct != null) ...[
                            const SizedBox(height: 8),
                            Card(
                              child: ListTile(
                                title: Text(selectedProduct.name),
                                subtitle: Text('Available stock: ${formatIntWithCommas(selectedProduct.stockQuantity)}'),
                                trailing: const Icon(Icons.inventory_2_outlined),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.icon(
                                key: const Key('inventory-stock-in'),
                                onPressed: () => _changeStock(stockIn: true),
                                icon: const Icon(Icons.add),
                                label: const Text('Stock in'),
                              ),
                              OutlinedButton.icon(
                                key: const Key('inventory-stock-out'),
                                onPressed: () => _changeStock(stockIn: false),
                                icon: const Icon(Icons.remove),
                                label: const Text('Stock out'),
                              ),
                              OutlinedButton.icon(
                                key: const Key('inventory-adjust'),
                                onPressed: _adjustStock,
                                icon: const Icon(Icons.tune),
                                label: const Text('Adjust'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text('Movement history', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          if (_movements.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: Text('No stock movements recorded yet.')),
                            )
                          else
                            ..._movements.map((movement) => Card(
                              child: ListTile(
                                leading: Icon(
                                  movement.quantityDelta > 0 ? Icons.trending_up :
                                      movement.movementType == 'sale' ? Icons.point_of_sale : Icons.trending_down,
                                ),
                                title: Text('${_movementLabel(movement)} · ${movement.quantityDelta > 0 ? '+' : ''}${formatIntWithCommas(movement.quantityDelta)}'),
                                subtitle: Text('${movement.reason}\nBalance after: ${formatIntWithCommas(movement.quantityAfter)} · ${movement.createdAt.toLocal()}'),
                                isThreeLine: true,
                              ),
                            )),
                        ],
                      ),
                    ),
    );
  }
}
