import 'package:sqflite/sqflite.dart';
import 'product_repository.dart';

class PurchaseRepository {
  PurchaseRepository({required ProductRepository products}) : _products = products;
  final ProductRepository _products;

  Future<void> _ensureTables(DatabaseExecutor db) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS purchase_receipts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      supplier_name TEXT NOT NULL,
      total_cost_cents INTEGER NOT NULL CHECK(total_cost_cents > 0),
      created_at TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE IF NOT EXISTS purchase_receipt_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      receipt_id INTEGER NOT NULL REFERENCES purchase_receipts(id),
      product_id INTEGER NOT NULL,
      product_name TEXT NOT NULL,
      quantity INTEGER NOT NULL CHECK(quantity > 0),
      unit_cost_cents INTEGER NOT NULL CHECK(unit_cost_cents > 0),
      line_total_cents INTEGER NOT NULL CHECK(line_total_cents > 0)
    )''');
    await db.execute('CREATE INDEX IF NOT EXISTS purchase_items_receipt_index ON purchase_receipt_items(receipt_id)');
  }

  Future<int> receivePurchase({required String supplierName, required int productId, required int quantity, required int unitCostCents}) async {
    final supplier = supplierName.trim();
    if (supplier.isEmpty) throw ArgumentError('Supplier name is required.');
    if (quantity < 1 || quantity > 999999) throw ArgumentError('Received quantity must be between 1 and 999999.');
    if (unitCostCents < 1) throw ArgumentError('Unit acquisition cost must be greater than zero.');
    final lineTotal = quantity * unitCostCents;
    if (lineTotal <= 0) throw ArgumentError('Purchase total is invalid.');
    final db = await _products.database;
    await _ensureTables(db);
    return db.transaction((txn) async {
      final rows = await txn.query('products', columns: ['id', 'name', 'stock_quantity', 'is_active', 'average_cost_cents'], where: 'id = ?', whereArgs: [productId], limit: 1);
      if (rows.isEmpty || rows.single['is_active'] != 1) throw StateError('An active product must be selected.');
      final product = rows.single;
      final before = product['stock_quantity'] as int;
      final after = before + quantity;
      if (after > 999999) throw StateError('Stock quantity cannot exceed 999999.');
      final oldAverageCost = product['average_cost_cents'] as int?;
      // If existing units have unknown acquisition cost, do not assign the
      // new receipt's cost to those units. Keep WAC unknown until the owner
      // explicitly values opening stock. A known WAC can be weighted normally.
      final int? averageCost;
      if (before == 0) {
        averageCost = unitCostCents;
      } else if (oldAverageCost == null) {
        averageCost = null;
      } else {
        averageCost = ((before * oldAverageCost + quantity * unitCostCents + (after ~/ 2)) ~/ after);
      }
      final now = DateTime.now().toIso8601String();
      final receiptId = await txn.insert('purchase_receipts', {'supplier_name': supplier, 'total_cost_cents': lineTotal, 'created_at': now});
      await txn.insert('purchase_receipt_items', {
        'receipt_id': receiptId, 'product_id': productId, 'product_name': product['name'],
        'quantity': quantity, 'unit_cost_cents': unitCostCents, 'line_total_cents': lineTotal,
      });
      final changed = await txn.rawUpdate('UPDATE products SET stock_quantity = ?, average_cost_cents = ?, updated_at = ? WHERE id = ? AND stock_quantity = ?', [after, averageCost, now, productId, before]);
      if (changed != 1) throw StateError('Stock changed while recording the purchase.');
      await txn.insert('stock_movements', {
        'product_id': productId, 'product_name': product['name'], 'movement_type': 'stock_in',
        'quantity_delta': quantity, 'quantity_after': after,
        'reason': 'Purchase receipt #$receiptId from $supplier', 'created_at': now,
      });
      return receiptId;
    });
  }

  Future<List<Map<String, Object?>>> getReceipts() async {
    final db = await _products.database;
    await _ensureTables(db);
    return db.query('purchase_receipts', orderBy: 'id DESC');
  }

  Future<List<Map<String, Object?>>> getReceiptItems(int receiptId) async {
    final db = await _products.database;
    await _ensureTables(db);
    return db.query('purchase_receipt_items', where: 'receipt_id = ?', whereArgs: [receiptId], orderBy: 'id ASC');
  }
}
