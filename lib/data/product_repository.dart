import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';
import '../models/stock_movement.dart';

abstract interface class ProductStore {
  Future<List<Product>> getProducts({bool includeInactive = false});
  Future<int> saveProduct(Product product);
  Future<void> deactivateProduct(int id);
}

class ProductRepository implements ProductStore {
  ProductRepository._();

  /// Creates a repository around an existing database, useful for isolated tests.
  ProductRepository.forDatabase(Database database) : _database = database;

  static final ProductRepository instance = ProductRepository._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final databasePath = path.join(await getDatabasesPath(), 'grocery_business.db');
    _database = await openDatabase(
      databasePath,
      version: 5,
      onCreate: (db, version) async {
        await _createProducts(db);
        await _createSales(db);
        await _createStockCapTriggers(db);
        await _createStockMovements(db);
        await _createCostingColumns(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createSales(db);
        await _createStockCapTriggers(db);
        if (oldVersion < 3) await _createStockMovements(db);
        if (oldVersion < 4) {
          await db.execute("ALTER TABLE products ADD COLUMN description TEXT NOT NULL DEFAULT ''");
        }
        if (oldVersion < 5) await _createCostingColumns(db);
      },
    );
    return _database!;
  }

  Future<void> _createCostingColumns(DatabaseExecutor db) async {
    await db.execute('ALTER TABLE products ADD COLUMN average_cost_cents INTEGER');
    await db.execute('ALTER TABLE sale_items ADD COLUMN unit_cost_cents INTEGER');
    await db.execute('ALTER TABLE sale_items ADD COLUMN line_cost_cents INTEGER');
    await db.execute('ALTER TABLE sales ADD COLUMN total_cogs_cents INTEGER');
  }

  Future<void> _createProducts(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL COLLATE NOCASE,
        description TEXT NOT NULL DEFAULT '',
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

  Future<void> _createStockMovements(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_movements (
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
    await db.execute('CREATE INDEX IF NOT EXISTS stock_movements_product_index ON stock_movements(product_id, id DESC)');
  }

  /// Adds or removes stock and records the change atomically.
  Future<void> changeStock({
    required int productId,
    required int quantity,
    required bool stockIn,
    required String reason,
  }) async {
    if (quantity <= 0 || quantity > 999999) {
      throw ArgumentError('Movement quantity must be between 1 and 999999.');
    }
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) throw ArgumentError('A reason is required.');
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.query('products',
          where: 'id = ?', whereArgs: [productId], limit: 1);
      if (rows.isEmpty) throw StateError('Product not found.');
      final row = rows.single;
      final before = row['stock_quantity'] as int;
      final delta = stockIn ? quantity : -quantity;
      final after = before + delta;
      if (after < 0) throw StateError('Stock-out exceeds available stock.');
      if (after > 999999) throw StateError('Stock quantity cannot exceed 999999.');
      final now = DateTime.now().toIso8601String();
      await txn.update('products', {
        'stock_quantity': after,
        'updated_at': now,
      }, where: 'id = ?', whereArgs: [productId]);
      await txn.insert('stock_movements', {
        'product_id': productId,
        'product_name': row['name'],
        'movement_type': stockIn ? 'stock_in' : 'stock_out',
        'quantity_delta': delta,
        'quantity_after': after,
        'reason': cleanReason,
        'created_at': now,
      });
    });
  }

  /// Sets the counted quantity and records the adjustment reason.
  Future<void> adjustStock({
    required int productId,
    required int targetQuantity,
    required String reason,
  }) async {
    if (targetQuantity < 0 || targetQuantity > 999999) {
      throw ArgumentError('Stock quantity must be between 0 and 999999.');
    }
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) throw ArgumentError('A reason is required.');
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.query('products',
          where: 'id = ?', whereArgs: [productId], limit: 1);
      if (rows.isEmpty) throw StateError('Product not found.');
      final row = rows.single;
      final before = row['stock_quantity'] as int;
      if (before == targetQuantity) {
        throw ArgumentError('Adjusted quantity must differ from current stock.');
      }
      final delta = targetQuantity - before;
      final now = DateTime.now().toIso8601String();
      await txn.update('products', {
        'stock_quantity': targetQuantity,
        'updated_at': now,
      }, where: 'id = ?', whereArgs: [productId]);
      await txn.insert('stock_movements', {
        'product_id': productId,
        'product_name': row['name'],
        'movement_type': 'adjustment',
        'quantity_delta': delta,
        'quantity_after': targetQuantity,
        'reason': cleanReason,
        'created_at': now,
      });
    });
  }

  Future<List<StockMovement>> getStockMovements({int? productId}) async {
    final db = await database;
    final rows = await db.query(
      'stock_movements',
      where: productId == null ? null : 'product_id = ?',
      whereArgs: productId == null ? null : [productId],
      orderBy: 'id DESC',
    );
    return rows.map(StockMovement.fromMap).toList(growable: false);
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
  /// Audits legacy records for product names that collide under the same
  /// trim-and-lowercase rule used by saveProduct. This is read-only: it never
  /// deletes, merges, renames, or deactivates products.
  Future<List<Map<String, Object?>>> findDuplicateProductNameGroups() async {
    final db = await database;
    return db.rawQuery('''
      SELECT
        lower(trim(name)) AS normalized_name,
        MIN(trim(name)) AS example_name,
        COUNT(*) AS duplicate_count,
        group_concat(id, ',') AS product_ids
      FROM products
      GROUP BY lower(trim(name))
      HAVING COUNT(*) > 1
      ORDER BY lower(trim(name)) ASC
    ''');
  }

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
    final normalizedName = name.toLowerCase();
    final duplicateRows = await db.query(
      'products',
      columns: ['id'],
      where: product.id == null
          ? 'lower(trim(name)) = ?'
          : 'lower(trim(name)) = ? AND id != ?',
      whereArgs: product.id == null
          ? [normalizedName]
          : [normalizedName, product.id],
      limit: 1,
    );
    if (duplicateRows.isNotEmpty) {
      throw StateError('A product with this name already exists. Edit the existing product or use a more specific name.');
    }
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
