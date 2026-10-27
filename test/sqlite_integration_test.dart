import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:grocery_business_app/data/product_repository.dart';
import 'package:grocery_business_app/data/sales_repository.dart';
import 'package:grocery_business_app/models/product.dart';

Future<Database> _openDatabase() async {
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  await db.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL COLLATE NOCASE,
      price_cents INTEGER NOT NULL CHECK(price_cents > 0),
      stock_quantity INTEGER NOT NULL CHECK(stock_quantity >= 0 AND stock_quantity <= 999999),
      is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0, 1)),
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  ''');
  await db.execute('''
    CREATE TABLE sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      created_at TEXT NOT NULL,
      total_cents INTEGER NOT NULL CHECK(total_cents >= 0),
      payment_cents INTEGER NOT NULL CHECK(payment_cents >= total_cents)
    )
  ''');
  await db.execute('''
    CREATE TABLE sale_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sale_id INTEGER NOT NULL REFERENCES sales(id),
      product_id INTEGER NOT NULL,
      product_name TEXT NOT NULL,
      quantity INTEGER NOT NULL CHECK(quantity > 0),
      unit_price_cents INTEGER NOT NULL CHECK(unit_price_cents > 0),
      line_total_cents INTEGER NOT NULL CHECK(line_total_cents > 0)
    )
  ''');
  await db.execute('''
    CREATE TABLE stock_movements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER NOT NULL,
      product_name TEXT NOT NULL,
      movement_type TEXT NOT NULL CHECK(movement_type IN ('stock_in', 'stock_out', 'adjustment', 'sale')),
      quantity_delta INTEGER NOT NULL CHECK(quantity_delta != 0),
      quantity_after INTEGER NOT NULL CHECK(quantity_after >= 0 AND quantity_after <= 999999),
      reason TEXT NOT NULL,
      created_at TEXT NOT NULL,
      sale_id INTEGER
    )
  ''');
  return db;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  late Database db;
  late ProductRepository products;
  late SaleRepository sales;

  setUp(() async {
    db = await _openDatabase();
    products = ProductRepository.forDatabase(db);
    sales = SaleRepository(products: products);
  });

  tearDown(() async {
    await db.close();
  });

  test('stock in, stock out, and adjustment write durable movement records', () async {
    final id = await products.saveProduct(const Product(
      name: 'Rice', priceCents: 500, stockQuantity: 10,
    ));

    await products.changeStock(
      productId: id, quantity: 5, stockIn: true, reason: 'Supplier delivery',
    );
    await products.changeStock(
      productId: id, quantity: 3, stockIn: false, reason: 'Damaged packs',
    );
    await products.adjustStock(
      productId: id, targetQuantity: 8, reason: 'Physical count',
    );

    final product = (await products.getProducts()).single;
    final movements = await products.getStockMovements(productId: id);
    expect(product.stockQuantity, 8);
    expect(movements, hasLength(3));
    expect(movements[0].movementType, 'adjustment');
    expect(movements[0].quantityDelta, -4);
    expect(movements[0].reason, 'Physical count');
    expect(movements[1].movementType, 'stock_out');
    expect(movements[1].quantityAfter, 12);
    expect(movements[2].movementType, 'stock_in');
    expect(movements[2].quantityAfter, 15);
  });

  test('stock movement rejects overdraw and quantities above the cap without writes', () async {
    final id = await products.saveProduct(const Product(
      name: 'Beans', priceCents: 250, stockQuantity: 10,
    ));

    await expectLater(
      products.changeStock(productId: id, quantity: 11, stockIn: false, reason: 'Test'),
      throwsStateError,
    );
    await expectLater(
      products.adjustStock(productId: id, targetQuantity: 1000000, reason: 'Test'),
      throwsArgumentError,
    );
    await expectLater(
      products.changeStock(productId: id, quantity: 999999, stockIn: true, reason: 'Test'),
      throwsStateError,
    );

    expect((await products.getProducts()).single.stockQuantity, 10);
    expect(await products.getStockMovements(productId: id), isEmpty);
  });

  test('sale, stock deduction, sale items, and stock ledger commit together', () async {
    final id = await products.saveProduct(const Product(
      name: 'Sugar', priceCents: 500, stockQuantity: 5,
    ));

    final receipt = await sales.completeSale(
      quantities: {id: 2},
      paymentCents: 1200,
    );

    expect(receipt.totalCents, 1000);
    expect(receipt.changeCents, 200);
    expect((await products.getProducts()).single.stockQuantity, 3);
    expect(await db.query('sales'), hasLength(1));
    expect(await db.query('sale_items'), hasLength(1));
    final movements = await products.getStockMovements(productId: id);
    expect(movements, hasLength(1));
    expect(movements.single.movementType, 'sale');
    expect(movements.single.quantityDelta, -2);
    expect(movements.single.quantityAfter, 3);
    expect(movements.single.saleId, receipt.id);
  });

  test('failed sale rolls back sale rows, stock deduction, and ledger entries', () async {
    final id = await products.saveProduct(const Product(
      name: 'Flour', priceCents: 300, stockQuantity: 2,
    ));

    await expectLater(
      sales.completeSale(quantities: {id: 3}, paymentCents: 900),
      throwsStateError,
    );

    expect((await products.getProducts()).single.stockQuantity, 2);
    expect(await db.query('sales'), isEmpty);
    expect(await db.query('sale_items'), isEmpty);
    expect(await products.getStockMovements(productId: id), isEmpty);
  });

  test('insufficient payment creates no sale and leaves stock untouched', () async {
    final id = await products.saveProduct(const Product(
      name: 'Oil', priceCents: 400, stockQuantity: 4,
    ));

    await expectLater(
      sales.completeSale(quantities: {id: 2}, paymentCents: 799),
      throwsArgumentError,
    );

    expect((await products.getProducts()).single.stockQuantity, 4);
    expect(await db.query('sales'), isEmpty);
    expect(await db.query('sale_items'), isEmpty);
    expect(await products.getStockMovements(productId: id), isEmpty);
  });
}
