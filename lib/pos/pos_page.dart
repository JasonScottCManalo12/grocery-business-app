import 'package:flutter/material.dart';

import '../data/product_repository.dart';
import '../data/sales_repository.dart';
import '../models/product.dart';
import '../models/sale.dart';

class PosPage extends StatefulWidget {
  const PosPage({super.key, required this.products, required this.sales});

  final ProductStore products;
  final SaleStore sales;

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  final _paymentController = TextEditingController();
  final _productSearchController = TextEditingController();
  List<Product> _products = [];
  List<SaleReceipt> _history = [];
  final Map<int, int> _cart = {};
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  int get _totalCents => _products.fold<int>(0, (sum, product) {
        final quantity = _cart[product.id] ?? 0;
        return sum + product.priceCents * quantity;
      });

  int get _paymentCents {
    final amount = double.tryParse(_paymentController.text.trim());
    if (amount == null || !amount.isFinite || amount < 0) return -1;
    return (amount * 100).round();
  }

  @override
  void initState() {
    super.initState();
    _paymentController.addListener(_refresh);
    _productSearchController.addListener(_refresh);
    _load();
  }

  @override
  void dispose() {
    _paymentController
      ..removeListener(_refresh)
      ..dispose();
    _productSearchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      final products = await widget.products.getProducts();
      final history = await widget.sales.getSales();
      if (!mounted) return;
      setState(() {
        _products = products.where((p) => p.id != null && p.isActive).toList();
        _history = history;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load products or sales history.';
      });
    }
  }

  void _changeQuantity(Product product, int next) {
    if (product.id == null) return;
    setState(() {
      if (next <= 0) {
        _cart.remove(product.id);
      } else if (next <= product.stockQuantity) {
        _cart[product.id!] = next;
      } else {
        _error = 'Only ${product.stockQuantity} units of ${product.name} are available.';
      }
    });
  }

  String _money(int cents) => '₱${(cents / 100).toStringAsFixed(2)}';

  Future<void> _confirmCheckout() async {
    if (_submitting || _cart.isEmpty) return;
    final payment = _paymentCents;
    if (payment < _totalCents) {
      setState(() => _error = 'Payment must be at least ${_money(_totalCents)}.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('sale-confirmation-dialog'),
        title: const Text('Confirm sale?'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Review this transaction before completing checkout.'),
              const SizedBox(height: 12),
              ..._products
                  .where((product) => _cart.containsKey(product.id))
                  .map((product) {
                final quantity = _cart[product.id]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${product.name} × $quantity — '
                    '${_money(product.priceCents * quantity)}',
                  ),
                );
              }),
              const Divider(),
              Text('Total: ${_money(_totalCents)}'),
              Text('Payment received: ${_money(payment)}'),
              Text('Change: ${_money(payment - _totalCents)}'),
              const SizedBox(height: 8),
              const Text('Confirming will save the sale and deduct stock.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('cancel-sale-confirmation'),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Go back'),
          ),
          FilledButton(
            key: const Key('confirm-sale'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm sale'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) await _checkout();
  }

  Future<void> _checkout() async {
    if (_submitting || _cart.isEmpty) return;
    final payment = _paymentCents;
    if (payment < _totalCents) {
      setState(() => _error = 'Payment must be at least ${_money(_totalCents)}.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final receipt = await widget.sales.completeSale(
        quantities: Map<int, int>.from(_cart),
        paymentCents: payment,
      );
      if (!mounted) return;
      setState(() {
        _cart.clear();
        _paymentController.clear();
        _history = [receipt, ..._history];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale #${receipt.id} completed. Change: ${_money(receipt.changeCents)}')),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Bad state: ', '').replaceFirst('Invalid argument(s): ', ''));
      await _load();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartLines = _products.where((p) => _cart.containsKey(p.id)).toList();
    final query = _productSearchController.text.trim().toLowerCase();
    final visibleProducts = _products.where((product) =>
      product.name.toLowerCase().contains(query) ||
      product.description.toLowerCase().contains(query)).toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: const Text('POS Checkout')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _products.isEmpty
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Products', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      if (_products.isEmpty)
                        const Text('Add active products in the catalogue before checkout.')
                      else ...[
                        TextField(
                          key: const Key('pos-product-search'),
                          controller: _productSearchController,
                          decoration: InputDecoration(
                            labelText: 'Search products',
                            hintText: 'Name or description',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _productSearchController.text.isEmpty ? null : IconButton(
                              tooltip: 'Clear product search',
                              onPressed: _productSearchController.clear,
                              icon: const Icon(Icons.clear),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 260,
                          child: visibleProducts.isEmpty
                            ? const Center(child: Text('No matching products'))
                            : ListView.builder(
                                key: const Key('pos-product-list'),
                                itemCount: visibleProducts.length,
                                itemBuilder: (context, index) {
                                  final product = visibleProducts[index];
                                  final quantity = _cart[product.id] ?? 0;
                                  return Card(
                                    child: ListTile(
                                      title: Text(product.name),
                                      subtitle: Text([
                                        if (product.description.trim().isNotEmpty) product.description.trim(),
                                        '${_money(product.priceCents)} · Stock: ${product.stockQuantity}',
                                      ].join(' · ')),
                                      trailing: FilledButton.tonalIcon(
                                        key: Key('add-cart-${product.id}'),
                                        onPressed: product.stockQuantity <= quantity
                                            ? null
                                            : () => _changeQuantity(product, quantity + 1),
                                        icon: const Icon(Icons.add_shopping_cart),
                                        label: Text(quantity == 0 ? 'Add' : '$quantity'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ),
                      ],
                      const Divider(height: 28),
                      Text('Cart', style: Theme.of(context).textTheme.titleLarge),
                      if (cartLines.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Cart is empty'),
                        ),
                      ...cartLines.map((product) {
                        final quantity = _cart[product.id]!;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(product.name),
                          subtitle: Text('${_money(product.priceCents)} × $quantity = ${_money(product.priceCents * quantity)}'),
                          trailing: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 2,
                            children: [
                              IconButton(
                                key: Key('decrease-${product.id}'),
                                onPressed: () => _changeQuantity(product, quantity - 1),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('$quantity'),
                              IconButton(
                                key: Key('increase-${product.id}'),
                                onPressed: quantity >= product.stockQuantity
                                    ? null
                                    : () => _changeQuantity(product, quantity + 1),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                              IconButton(
                                key: Key('remove-${product.id}'),
                                tooltip: 'Remove item',
                                onPressed: () => _changeQuantity(product, 0),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(),
                      ListTile(
                        title: const Text('Subtotal / Total'),
                        trailing: Text(
                          _money(_totalCents),
                          key: const Key('pos-total'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextField(
                        key: const Key('payment-received'),
                        controller: _paymentController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Payment received (PHP)',
                          prefixText: '₱ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: const Text('Change'),
                        trailing: Text(
                          _paymentCents >= _totalCents && _paymentCents >= 0
                              ? _money(_paymentCents - _totalCents)
                              : '—',
                          key: const Key('pos-change'),
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ),
                      FilledButton.icon(
                        key: const Key('complete-sale'),
                        onPressed: _submitting || _cart.isEmpty || _paymentCents < _totalCents
                            ? null
                            : _confirmCheckout,
                        icon: _submitting
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.point_of_sale),
                        label: Text(_submitting ? 'Completing sale…' : 'Complete sale'),
                      ),
                      const Divider(height: 32),
                      Text('Transaction history', style: Theme.of(context).textTheme.titleLarge),
                      if (_history.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('No completed sales yet'),
                        ),
                      ..._history.map((sale) => Card(
                        child: ExpansionTile(
                          key: Key('sale-${sale.id}'),
                          title: Text('Sale #${sale.id} · ${_money(sale.totalCents)}'),
                          subtitle: Text(sale.createdAt.toLocal().toString()),
                          children: [
                            ...sale.lines.map((line) => ListTile(
                              dense: true,
                              title: Text(line.productName),
                              subtitle: Text('Qty ${line.quantity} × ${_money(line.unitPriceCents)}'),
                              trailing: Text(_money(line.lineTotalCents)),
                            )),
                            ListTile(title: const Text('Payment'), trailing: Text(_money(sale.paymentCents))),
                            ListTile(title: const Text('Change'), trailing: Text(_money(sale.changeCents))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
    );
  }
}
