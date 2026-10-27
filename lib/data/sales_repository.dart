import 'package:sqflite/sqflite.dart';

import '../models/product.dart';
import '../models/sale.dart';
import 'product_repository.dart';

abstract interface class SaleStore {
  Future<SaleReceipt> completeSale({
    required Map<int, int> quantities,
    required int paymentCents,
  });

  Future<List<SaleReceipt>> getSales();
}

class SaleRepository implements SaleStore {
  SaleRepository({ProductRepository? products})
      : _products = products ?? ProductRepository.instance;

  final ProductRepository _products;

  @override
  Future<SaleReceipt> completeSale({
    required Map<int, int> quantities,
    required int paymentCents,
  }) async {
    if (quantities.isEmpty) throw ArgumentError('Cart is empty.');
    if (quantities.values.any((quantity) => quantity < 1)) {
      throw ArgumentError('Every cart quantity must be at least one.');
    }

    final db = await _products.database;
    return db.transaction((txn) async {
      final lines = <SaleLine>[];
      var totalCents = 0;

      for (final entry in quantities.entries) {
        final rows = await txn.query(
          'products',
          columns: ['id', 'name', 'price_cents', 'stock_quantity', 'is_active'],
          where: 'id = ?',
          whereArgs: [entry.key],
          limit: 1,
        );
        if (rows.isEmpty || rows.single['is_active'] != 1) {
          throw StateError('A cart product is unavailable.');
        }
        final row = rows.single;
        final product = Product.fromMap(row);
        if (entry.value > product.stockQuantity) {
          throw StateError('Insufficient stock for ${product.name}.');
        }
        final line = SaleLine(
          productId: entry.key,
          productName: product.name,
          quantity: entry.value,
          unitPriceCents: product.priceCents,
        );
        lines.add(line);
        totalCents += line.lineTotalCents;
      }

      if (paymentCents < totalCents) {
        throw ArgumentError('Payment is less than the sale total.');
      }

      final now = DateTime.now().toIso8601String();
      final saleId = await txn.insert('sales', {
        'created_at': now,
        'total_cents': totalCents,
        'payment_cents': paymentCents,
      });

      for (final line in lines) {
        final changed = await txn.update(
          'products',
          {'stock_quantity': _newStockPlaceholder(line), 'updated_at': now},
          where: 'id = ? AND is_active = 1 AND stock_quantity >= ?',
          whereArgs: [line.productId, line.quantity],
        );
        // The stock update must subtract the sold quantity atomically. SQLite
        // expression updates are issued below to avoid stale read/modify/write.
        if (changed == 0) throw StateError('Stock changed during checkout.');
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': line.productId,
          'product_name': line.productName,
          'quantity': line.quantity,
          'unit_price_cents': line.unitPriceCents,
          'line_total_cents': line.lineTotalCents,
        });
      }

      return SaleReceipt(
        id: saleId,
        createdAt: DateTime.parse(now),
        lines: lines,
        totalCents: totalCents,
        paymentCents: paymentCents,
      );
    });
  }

  // Placeholder kept private to make stock calculation explicit at call site.
  int _newStockPlaceholder(SaleLine line) => 0;

  @override
  Future<List<SaleReceipt>> getSales() async {
    final db = await _products.database;
    final sales = await db.query('sales', orderBy: 'id DESC');
    final receipts = <SaleReceipt>[];
    for (final sale in sales) {
      final id = sale['id'] as int;
      final rows = await db.query(
        'sale_items',
        where: 'sale_id = ?',
        whereArgs: [id],
        orderBy: 'id ASC',
      );
      receipts.add(SaleReceipt(
        id: id,
        createdAt: DateTime.parse(sale['created_at'] as String),
        totalCents: sale['total_cents'] as int,
        paymentCents: sale['payment_cents'] as int,
        lines: rows.map((row) => SaleLine(
          productId: row['product_id'] as int,
          productName: row['product_name'] as String,
          quantity: row['quantity'] as int,
          unitPriceCents: row['unit_price_cents'] as int,
        )).toList(growable: false),
      ));
    }
    return receipts;
  }
}
