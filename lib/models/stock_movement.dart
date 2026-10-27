class StockMovement {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.movementType,
    required this.quantityDelta,
    required this.quantityAfter,
    required this.reason,
    required this.createdAt,
    this.saleId,
  });

  final int id;
  final int productId;
  final String productName;
  /// stock_in, stock_out, adjustment, or sale
  final String movementType;
  /// Positive for additions, negative for removals; adjustment records the net change.
  final int quantityDelta;
  final int quantityAfter;
  final String reason;
  final DateTime createdAt;
  final int? saleId;

  factory StockMovement.fromMap(Map<String, Object?> map) => StockMovement(
        id: map['id'] as int,
        productId: map['product_id'] as int,
        productName: map['product_name'] as String,
        movementType: map['movement_type'] as String,
        quantityDelta: map['quantity_delta'] as int,
        quantityAfter: map['quantity_after'] as int,
        reason: map['reason'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        saleId: map['sale_id'] as int?,
      );
}
