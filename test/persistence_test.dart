import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_business_app/models/product.dart';

void main() {
  test('product survives map round trip used by SQLite repository', () {
    const original = Product(
      id: 7,
      name: 'Rice',
      priceCents: 5550,
      stockQuantity: 12,
    );

    final restored = Product.fromMap(original.toMap());

    expect(restored.id, original.id);
    expect(restored.name, original.name);
    expect(restored.priceCents, original.priceCents);
    expect(restored.stockQuantity, original.stockQuantity);
    expect(restored.isActive, original.isActive);
  });
}
