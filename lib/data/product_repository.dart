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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL COLLATE NOCASE,
            price_cents INTEGER NOT NULL CHECK(price_cents > 0),
            stock_quantity INTEGER NOT NULL CHECK(stock_quantity >= 0),
            is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0, 1)),
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        ''');
        await db.execute(
          'CREATE INDEX products_name_index ON products(name)',
        );
      },
    );
    return _database!;
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
    if (product.stockQuantity < 0) {
      throw ArgumentError('Stock quantity cannot be negative.');
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
