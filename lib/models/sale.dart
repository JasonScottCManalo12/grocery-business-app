class SaleLine {
  const SaleLine({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPriceCents,
    this.unitCostCents,
  });

  final int productId;
  final String productName;
  final int quantity;
  final int unitPriceCents;
  final int? unitCostCents;
  int? get lineCostCents => unitCostCents == null ? null : quantity * unitCostCents!;

  int get lineTotalCents => quantity * unitPriceCents;
}

class SaleReceipt {
  const SaleReceipt({
    required this.id,
    required this.createdAt,
    required this.lines,
    required this.totalCents,
    required this.paymentCents,
    this.totalCogsCents,
  });

  final int id;
  final DateTime createdAt;
  final List<SaleLine> lines;
  final int totalCents;
  final int paymentCents;
  final int? totalCogsCents;
  int? get grossProfitCents => totalCogsCents == null ? null : totalCents - totalCogsCents!;

  int get changeCents => paymentCents - totalCents;
}
