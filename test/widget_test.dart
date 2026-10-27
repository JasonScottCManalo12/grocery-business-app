import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_business_app/data/product_repository.dart';
import 'package:grocery_business_app/main.dart';
import 'package:grocery_business_app/models/product.dart';

class MemoryProductStore implements ProductStore {
  final List<Product> products = [];
  int _nextId = 1;

  @override
  Future<List<Product>> getProducts({bool includeInactive = false}) async {
    return products
        .where((product) => includeInactive || product.isActive)
        .toList(growable: false);
  }

  @override
  Future<int> saveProduct(Product product) async {
    if (product.id == null) {
      final saved = Product(
        id: _nextId++,
        name: product.name,
        priceCents: product.priceCents,
        stockQuantity: product.stockQuantity,
        isActive: product.isActive,
      );
      products.add(saved);
      return saved.id!;
    }
    final index = products.indexWhere((item) => item.id == product.id);
    if (index < 0) throw StateError('Product not found');
    products[index] = product;
    return product.id!;
  }

  @override
  Future<void> deactivateProduct(int id) async {
    final index = products.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Product not found');
    final product = products[index];
    products[index] = Product(
      id: product.id,
      name: product.name,
      priceCents: product.priceCents,
      stockQuantity: product.stockQuantity,
      isActive: false,
    );
  }
}

void main() {
  testWidgets('shows empty catalogue and adds a product', (tester) async {
    final store = MemoryProductStore();
    await tester.pumpWidget(MyApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('No products yet'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-product-button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('product-name')), 'Rice');
    await tester.enterText(find.byKey(const Key('product-price')), '55.50');
    await tester.enterText(find.byKey(const Key('product-stock')), '12');
    await tester.tap(find.byKey(const Key('save-product')));
    await tester.pumpAndSettle();

    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('₱55.50'), findsOneWidget);
    expect(find.text('Stock: 12'), findsOneWidget);
    expect(store.products, hasLength(1));
    expect(store.products.single.priceCents, 5550);
  });

  testWidgets('rejects an empty name and zero selling price', (tester) async {
    await tester.pumpWidget(MyApp(store: MemoryProductStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-product-button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('product-name')), '   ');
    await tester.enterText(find.byKey(const Key('product-price')), '0');
    await tester.enterText(find.byKey(const Key('product-stock')), '-1');
    await tester.tap(find.byKey(const Key('save-product')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a product name.'), findsOneWidget);
    expect(find.text('Enter a price greater than zero.'), findsOneWidget);
    expect(find.text('Enter a whole quantity of zero or more.'), findsOneWidget);
    expect(find.text('Add product'), findsOneWidget);
  });

  testWidgets('search filters the active product list', (tester) async {
    final store = MemoryProductStore()
      ..products.addAll(const [
        Product(id: 1, name: 'Rice', priceCents: 5550, stockQuantity: 12),
        Product(id: 2, name: 'Milk', priceCents: 1250, stockQuantity: 4),
      ]);
    await tester.pumpWidget(MyApp(store: store));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('product-search')), 'mil');
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Rice'), findsNothing);
  });
}
