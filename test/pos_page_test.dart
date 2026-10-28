import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_business_app/data/product_repository.dart';
import 'package:grocery_business_app/data/sales_repository.dart';
import 'package:grocery_business_app/models/product.dart';
import 'package:grocery_business_app/models/sale.dart';
import 'package:grocery_business_app/pos/pos_page.dart';

class _Products implements ProductStore {
  final items = <Product>[
    const Product(id: 1, name: 'Rice', priceCents: 500, stockQuantity: 5),
  ];

  @override
  Future<List<Product>> getProducts({bool includeInactive = false}) async =>
      items.where((p) => includeInactive || p.isActive).toList();

  @override
  Future<int> saveProduct(Product product) async => product.id ?? 2;

  @override
  Future<void> deactivateProduct(int id) async {}
  testWidgets('comma-formatted payment can complete a sale and supports many digits', (tester) async {
    final products = _Products();
    final sales = _Sales();
    await tester.pumpWidget(MaterialApp(
      home: PosPage(products: products, sales: sales),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-cart-1')));
    await tester.pumpAndSettle();
    await _scrollToPayment(tester);

    final field = find.byKey(const Key('payment-received'));
    await tester.enterText(field, '1234567.00');
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, '1,234,567.00');
    expect(find.text('₱1,234,562.00'), findsOneWidget);

    await tester.enterText(field, '1,000.00');
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, '1,000.00');
    await tester.tap(find.byKey(const Key('complete-sale')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sale-confirmation-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-sale')));
    await tester.pumpAndSettle();
    expect(sales.completedCount, 1);
    expect(sales.history.first.paymentCents, 100000);
  });

}

class _Sales implements SaleStore {
  int completedCount = 0;
  final history = <SaleReceipt>[];

  @override
  Future<SaleReceipt> completeSale({
    required Map<int, int> quantities,
    required int paymentCents,
  }) async {
    completedCount++;
    final line = SaleLine(
      productId: 1,
      productName: 'Rice',
      quantity: quantities[1]!,
      unitPriceCents: 500,
    );
    final receipt = SaleReceipt(
      id: completedCount,
      createdAt: DateTime(2026, 10, 27),
      lines: [line],
      totalCents: line.lineTotalCents,
      paymentCents: paymentCents,
    );
    history.insert(0, receipt);
    return receipt;
  }

  @override
  Future<List<SaleReceipt>> getSales() async => List.of(history);
}

Future<void> _scrollToPayment(WidgetTester tester) async {
  // These widget tests focus on checkout logic, not scrolling mechanics.
  // Use a tall test viewport so the payment field is built by the ListView.
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('payment-received')), findsOneWidget);
}

void main() {
  testWidgets('cart quantities, total, payment and change work', (tester) async {
    final products = _Products();
    final sales = _Sales();
    await tester.pumpWidget(MaterialApp(
      home: PosPage(products: products, sales: sales),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-cart-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('increase-1')));
    await tester.pumpAndSettle();

    expect(find.text('₱10.00'), findsOneWidget);
    await _scrollToPayment(tester);
    await tester.enterText(find.byKey(const Key('payment-received')), '20.00');
    await tester.pumpAndSettle();
    expect(find.text('₱10.00'), findsNWidgets(2));
    expect(find.byKey(const Key('complete-sale')), findsOneWidget);
  });

  testWidgets('completed sale is submitted once and shown in history', (tester) async {
    final products = _Products();
    final sales = _Sales();
    await tester.pumpWidget(MaterialApp(
      home: PosPage(products: products, sales: sales),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-cart-1')));
    await tester.pumpAndSettle();
    await _scrollToPayment(tester);
    await tester.enterText(find.byKey(const Key('payment-received')), '5.00');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('complete-sale')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sale-confirmation-dialog')), findsOneWidget);
    expect(find.text('Total: ₱5.00'), findsOneWidget);
    expect(find.text('Payment received: ₱5.00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-sale')));
    await tester.pumpAndSettle();

    expect(sales.completedCount, 1);
    expect(find.text('Sale #1 · ₱5.00'), findsOneWidget);
    expect(find.text('Cart is empty'), findsOneWidget);
  });

  testWidgets('canceling sale confirmation does not submit the sale', (tester) async {
    final products = _Products();
    final sales = _Sales();
    await tester.pumpWidget(MaterialApp(
      home: PosPage(products: products, sales: sales),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-cart-1')));
    await tester.pumpAndSettle();
    await _scrollToPayment(tester);
    await tester.enterText(find.byKey(const Key('payment-received')), '5.00');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('complete-sale')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cancel-sale-confirmation')));
    await tester.pumpAndSettle();

    expect(sales.completedCount, 0);
    expect(find.text('Cart is empty'), findsNothing);
    expect(find.byKey(const Key('sale-confirmation-dialog')), findsNothing);
  });
}
