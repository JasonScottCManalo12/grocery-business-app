import 'package:flutter/material.dart';

import '../data/product_repository.dart';
import '../data/sales_repository.dart';
import '../models/sale.dart';
import '../utils/number_format.dart';

/// Read-only Phase 1 accounting summary. Unknown acquisition costs are kept
/// explicitly unknown and excluded from valuation / profit totals.
class AccountingPage extends StatefulWidget {
  const AccountingPage({super.key, required this.repository});
  final ProductRepository repository;
  @override
  State<AccountingPage> createState() => _AccountingPageState();
}

class _AccountingPageState extends State<AccountingPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, Object?>> _products = [];
  List<SaleReceipt> _sales = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final db = await widget.repository.database;
      final products = await db.query('products', where: 'is_active = 1', orderBy: 'name COLLATE NOCASE');
      final sales = await SaleRepository(products: widget.repository).getSales();
      if (!mounted) return;
      setState(() { _products = products; _sales = sales; _loading = false; _error = null; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Could not load accounting data. Check the database schema and try again.'; });
    }
  }

  String _money(int cents) => formatMoneyCents(cents);

  int get _knownInventoryValue => _products.fold<int>(0, (sum, product) {
    final quantity = product['stock_quantity'] as int;
    final cost = product['average_cost_cents'] as int?;
    return sum + (cost == null ? 0 : quantity * cost);
  });

  int get _unknownCostProductCount => _products.where((p) =>
    (p['stock_quantity'] as int) > 0 && p['average_cost_cents'] == null).length;

  int get _knownRevenue => _sales.where((s) => s.totalCogsCents != null)
      .fold<int>(0, (sum, sale) => sum + sale.totalCents);

  int get _knownCogs => _sales.fold<int>(0, (sum, sale) =>
      sum + (sale.totalCogsCents ?? 0));

  int get _unknownCostSalesCount => _sales.where((s) => s.totalCogsCents == null).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Valuation & Gross Profit'),
        actions: [IconButton(key: const Key('refresh-accounting'), tooltip: 'Refresh accounting data', onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Current inventory valuation', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Valued inventory (known WAC only)'),
                        const SizedBox(height: 4),
                        Text(_money(_knownInventoryValue), style: Theme.of(context).textTheme.headlineSmall),
                        if (_unknownCostProductCount > 0) ...[
                          const SizedBox(height: 8),
                          Text('$_unknownCostProductCount product(s) with stock have unknown acquisition cost and are excluded from this value.', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ],
                      ]))),
                      const SizedBox(height: 16),
                      Text('Product cost details', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      if (_products.isEmpty) const Text('No active products.')
                      else ..._products.map((product) {
                        final quantity = product['stock_quantity'] as int;
                        final cost = product['average_cost_cents'] as int?;
                        final value = cost == null ? null : cost * quantity;
                        return Card(child: ListTile(
                          title: Text(product['name'] as String),
                          subtitle: Text('On hand: ${formatIntWithCommas(quantity)} · WAC: ${cost == null ? 'Unknown' : _money(cost)}'),
                          trailing: Text(value == null ? 'Unknown value' : _money(value), textAlign: TextAlign.end),
                        ));
                      }),
                      const SizedBox(height: 16),
                      Text('Gross-profit summary (all recorded sales)', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _metric('Sales revenue with known COGS', _money(_knownRevenue)),
                        _metric('COGS for sales with known cost', _money(_knownCogs)),
                        _metric('Gross profit for sales with known cost', _money(_knownRevenue - _knownCogs)),
                        if (_unknownCostSalesCount > 0) ...[
                          const Divider(),
                          Text('$_unknownCostSalesCount sale(s) have unknown COGS. They are excluded from the gross-profit total.', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ],
                        const SizedBox(height: 8),
                        const Text('This is a lifetime summary, not a date-filtered accounting statement. It excludes operating expenses and does not represent net profit.'),
                      ]))),
                      const SizedBox(height: 16),
                      Text('Recent sales', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      if (_sales.isEmpty) const Text('No sales recorded.')
                      else ..._sales.map((sale) => Card(child: ListTile(
                        title: Text('Sale #${sale.id} · ${_money(sale.totalCents)}'),
                        subtitle: Text('COGS: ${sale.totalCogsCents == null ? 'Unknown' : _money(sale.totalCogsCents!)} · Gross profit: ${sale.grossProfitCents == null ? 'Unknown' : _money(sale.grossProfitCents!)}'),
                        trailing: Text('${sale.lines.length} item(s)'),
                      ))),
                    ],
                  ),
                ),
    );
  }

  Widget _metric(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Text(label)),
      const SizedBox(width: 12),
      Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]),
  );
}
