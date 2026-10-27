import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';

abstract interface class ProductStore {
  Future<List<Product>> getProducts({bool includeInactive = false});
  Future<int> saveProduct(Product product);
  Future<void> deactivateProduct(int id);
}

class ProductRepository implements ProductStore {
  ProductRepository._();

  static final ProductRepository instance = ProductRepository._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final databasePath = path.join(await getDatabasesPath(), 'grocery_business.db');
    _database = await openDatabase(
      databasePath,
      version: 2,
      onCreate: (db, version) async {
        await _createProducts(db);
        await _createSales(db);
        await _createStockCapTriggers(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createSales(db);
        await _createStockCapTriggers(db);
      },
    );
    return _database!;
  }

  Future<void> _createProducts(DatabaseExecutor db) async {
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
    await db.execute('CREATE INDEX products_name_index ON products(name)');
  }

  Future<void> _createSales(DatabaseExecutor db) async {
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
    await db.execute('CREATE INDEX sale_items_sale_id_index ON sale_items(sale_id)');
  }

  Future<void> _createStockCapTriggers(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS products_stock_cap_insert
      BEFORE INSERT ON products
      WHEN NEW.stock_quantity < 0 OR NEW.stock_quantity > 999999
      BEGIN
        SELECT RAISE(ABORT, 'Stock quantity must be between 0 and 999999.');
      END
    ''');
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS products_stock_cap_update
      BEFORE UPDATE OF stock_quantity ON products
      WHEN NEW.stock_quantity < 0 OR NEW.stock_quantity > 999999
      BEGIN
        SELECT RAISE(ABORT, 'Stock quantity must be between 0 and 999999.');
      END
    ''');
  }

  @override
  Future<List<Product>> getProducts({bool includeInactive = false}) async {
    final db = await database;
    final rows = await db.query(
      'products',
      where: includeInactive ? null : 'is_active = ?',
      whereArgs: includeInactive ? null : [1],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Product.fromMap).toList(growable: false);
  }

  @override
  Future<int> saveProduct(Product product) async {
    final name = product.name.trim();
    if (name.isEmpty) throw ArgumentError('Product name is required.');
    if (product.priceCents <= 0) {
      throw ArgumentError('Selling price must be greater than zero.');
    }
    if (product.stockQuantity < 0 || product.stockQuantity > 999999) {
      throw ArgumentError('Stock quantity must be between 0 and 999999.');
    }

    final db = await database;
    final values = product.toMap()
      ..remove('id')
      ..['name'] = name
      ..['updated_at'] = DateTime.now().toIso8601String();

    if (product.id == null) {
      values['created_at'] = DateTime.now().toIso8601String();
      return db.insert('products', values);
    }

    final changed = await db.update(
      'products',
      values,
      where: 'id = ?',
      whereArgs: [product.id],
    );
    if (changed == 0) throw StateError('Product no longer exists.');
    return product.id!;
  }

  @override
  Future<void> deactivateProduct(int id) async {
    final db = await database;
    final changed = await db.update(
      'products',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ? AND is_active = 1',
      whereArgs: [id],
    );
    if (changed == 0) throw StateError('Active product not found.');
  }
}
