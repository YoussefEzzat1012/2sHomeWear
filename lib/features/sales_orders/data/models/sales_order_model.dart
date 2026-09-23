class SalesOrderModel {
  final int id;
  final String name; // Order Number (e.g., S00003)
  final int partnerId;
  final String partnerName;
  final String dateOrder;
  final String state; // draft, sent, sale, cancel
  final double amountTotal;
  final List<SalesOrderLineModel> orderLines;

  SalesOrderModel({
    required this.id,
    required this.name,
    required this.partnerId,
    required this.partnerName,
    required this.dateOrder,
    required this.state,
    required this.amountTotal,
    this.orderLines = const [],
  });

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    final partnerData = json['partner_id'] as List<dynamic>?;

    return SalesOrderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      partnerId: (partnerData != null && partnerData.isNotEmpty)
          ? partnerData[0] as int
          : 0,
      partnerName: (partnerData != null && partnerData.length > 1)
          ? partnerData[1] as String
          : '',
      dateOrder: json['date_order'] ?? '',
      state: json['state'] ?? 'draft',
      amountTotal: (json['amount_total'] as num?)?.toDouble() ?? 0.0,
      orderLines: [],
    );
  }

  SalesOrderModel copyWith({
    String? state,
    List<SalesOrderLineModel>? orderLines,
  }) {
    return SalesOrderModel(
      id: id,
      name: name,
      partnerId: partnerId,
      partnerName: partnerName,
      dateOrder: dateOrder,
      state: state ?? this.state,
      amountTotal: amountTotal,
      orderLines: orderLines ?? this.orderLines,
    );
  }
}

class SalesOrderLineModel {
  final int id;
  final String productName;
  final double productUomQty;
  final double priceUnit;
  final double priceSubtotal;

  SalesOrderLineModel({
    required this.id,
    required this.productName,
    required this.productUomQty,
    required this.priceUnit,
    required this.priceSubtotal,
  });

  factory SalesOrderLineModel.fromJson(Map<String, dynamic> json) {
    final productData = json['product_id'] as List<dynamic>?;

    return SalesOrderLineModel(
      id: json['id'] ?? 0,
      productName: (productData != null && productData.length > 1)
          ? productData[1] as String
          : '',
      productUomQty: (json['product_uom_qty'] as num?)?.toDouble() ?? 0.0,
      priceUnit: (json['price_unit'] as num?)?.toDouble() ?? 0.0,
      priceSubtotal: (json['price_subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
