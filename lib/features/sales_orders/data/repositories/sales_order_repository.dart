import '../../../../core/network/odoo_api_client.dart';
import '../models/sales_order_model.dart';

class SalesOrderRepository {
  final OdooApiClient _apiClient;

  SalesOrderRepository(this._apiClient);

  Future<List<SalesOrderModel>> getSalesOrders() async {
    final List result = await _apiClient.callKw(
      model: 'sale.order',
      method: 'search_read',
      args: [],
      kwargs: {
        'fields': [
          'id',
          'name',
          'partner_id',
          'date_order',
          'state',
          'amount_total'
        ],
      },
    );

    return result.map((e) => SalesOrderModel.fromJson(e)).toList();
  }

  Future<List<SalesOrderLineModel>> getSalesOrderLines(int orderId) async {
    final List orderResult = await _apiClient.callKw(
      model: 'sale.order',
      method: 'search_read',
      args: [],
      kwargs: {
        'domain': [
          ['id', '=', orderId]
        ],
        'fields': ['order_line'],
      },
    );

    if (orderResult.isEmpty) return [];

    final List lineIds = orderResult.first['order_line'] ?? [];
    if (lineIds.isEmpty) return [];

    // جلب بيانات أسطر المنتجات التفصيلية
    final List linesResult = await _apiClient.callKw(
      model: 'sale.order.line',
      method: 'search_read',
      args: [],
      kwargs: {
        'domain': [
          ['id', 'in', lineIds]
        ],
        'fields': [
          'id',
          'product_id',
          'product_uom_qty',
          'price_unit',
          'price_subtotal'
        ],
      },
    );

    return linesResult.map((e) => SalesOrderLineModel.fromJson(e)).toList();
  }

  Future<bool> confirmSalesOrder(int orderId) async {
    final result = await _apiClient.callKw(
      model: 'sale.order',
      method: 'action_confirm',
      args: [
        [orderId]
      ],
    );

    return result == true;
  }
}
