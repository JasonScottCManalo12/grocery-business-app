class Product {
  const Product({
    this.id,
    required this.name,
    this.description = '',
    required this.priceCents,
    required this.stockQuantity,
    this.isActive = true,
  });

  final int? id;
  final String name;
  final String description;
  /// Store money as integer centavos to avoid floating-point rounding errors.
  final int priceCents;
  final int stockQuantity;
  final bool isActive;

  double get price => priceCents / 100;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name.trim(),
        'description': description.trim(),
        'price_cents': priceCents,
        'stock_quantity': stockQuantity,
        'is_active': isActive ? 1 : 0,
      };

  factory Product.fromMap(Map<String, Object?> map) => Product(
        id: map['id'] as int?,
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        priceCents: map['price_cents'] as int,
        stockQuantity: map['stock_quantity'] as int,
        isActive: (map['is_active'] as int) == 1,
      );
}
