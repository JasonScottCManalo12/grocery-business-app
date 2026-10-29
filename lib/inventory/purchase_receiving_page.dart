import 'package:flutter/material.dart';
import '../data/product_repository.dart';
import '../data/purchase_repository.dart';
import '../models/product.dart';
import '../utils/number_format.dart';

class PurchaseReceivingPage extends StatefulWidget {
  const PurchaseReceivingPage({super.key, required this.repository});
  final ProductRepository repository;
  @override
  State<PurchaseReceivingPage> createState() => _PurchaseReceivingPageState();
}

class _PurchaseReceivingPageState extends State<PurchaseReceivingPage> {
  final _formKey = GlobalKey<FormState>();
  final _supplierController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  List<Product> _products = [];
  int? _productId;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() { super.initState(); _loadProducts(); }
  @override
  void dispose() {
    _supplierController.dispose(); _quantityController.dispose(); _costController.dispose(); super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await widget.repository.getProducts();
      if (!mounted) return;
      setState(() { _products = products; _productId = products.isEmpty ? null : products.first.id; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Could not load products.'; });
    }
  }

  int? _parseQuantity(String value) => parseCommaSeparatedInt(value);
  double? _parseCost(String value) => parseCommaSeparatedDouble(value);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _productId == null) return;
    setState(() => _saving = true);
    try {
      final receiptId = await PurchaseRepository(products: widget.repository).receivePurchase(
        supplierName: _supplierController.text, productId: _productId!,
        quantity: _parseQuantity(_quantityController.text)!,
        unitCostCents: (_parseCost(_costController.text)! * 100).round(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Purchase receipt #$receiptId recorded.')));
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', '').replaceFirst('Invalid argument(s): ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Receive Purchase')),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : _error != null ? Center(child: Text(_error!))
      : _products.isEmpty ? const Center(child: Text('Add an active product before receiving a purchase.'))
      : Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Record the supplier delivery. Acquisition cost is separate from the product selling price.'),
        const SizedBox(height: 16),
        TextFormField(key: const Key('purchase-supplier'), controller: _supplierController,
          decoration: const InputDecoration(labelText: 'Supplier name'), textCapitalization: TextCapitalization.words,
          validator: (value) => value == null || value.trim().isEmpty ? 'Enter a supplier name.' : null),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(key: const Key('purchase-product'), value: _productId,
          decoration: const InputDecoration(labelText: 'Product received'),
          items: _products.map((product) => DropdownMenuItem<int>(value: product.id,
            child: Text('${product.name} · stock ${formatIntWithCommas(product.stockQuantity)}', overflow: TextOverflow.ellipsis))).toList(),
          onChanged: _saving ? null : (value) => setState(() => _productId = value)),
        const SizedBox(height: 12),
        TextFormField(key: const Key('purchase-quantity'), controller: _quantityController,
          decoration: const InputDecoration(labelText: 'Received quantity'), keyboardType: TextInputType.number,
          validator: (value) {
            final quantity = _parseQuantity(value ?? '');
            if (quantity == null || quantity < 1 || quantity > 999999) return 'Enter a whole quantity from 1 to 999999.';
            final matches = _products.where((item) => item.id == _productId);
            if (matches.isNotEmpty && quantity + matches.first.stockQuantity > 999999) return 'Received quantity exceeds available stock capacity.';
            return null;
          }),
        const SizedBox(height: 12),
        TextFormField(key: const Key('purchase-unit-cost'), controller: _costController,
          decoration: const InputDecoration(labelText: 'Actual unit acquisition cost (PHP)', prefixText: '₱ '),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final cost = _parseCost(value ?? '');
            if (cost == null || !cost.isFinite || cost <= 0 || cost > 999999999) return 'Enter a valid unit cost greater than zero.';
            return null;
          }),
        const SizedBox(height: 8),
        const Text('This does not change the selling price. If existing stock has unknown acquisition cost, the app will keep its WAC unknown rather than guessing.'),
        const SizedBox(height: 20),
        FilledButton(key: const Key('save-purchase-receipt'), onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving…' : 'Record purchase receipt')),
      ])),
  );
}
