import 'package:bloc/bloc.dart';

import '../data/models/sales_order_model.dart';
import '../data/repositories/sales_order_repository.dart';

abstract class SalesOrderState {}

class SalesOrderInitial extends SalesOrderState {}

class SalesOrderLoading extends SalesOrderState {}

class SalesOrderLoaded extends SalesOrderState {
  final List<SalesOrderModel> orders;

  SalesOrderLoaded(this.orders);
}

class SalesOrderDetailLoaded extends SalesOrderState {
  final SalesOrderModel selectedOrder;

  SalesOrderDetailLoaded(this.selectedOrder);
}

class SalesOrderConfirming extends SalesOrderState {}

class SalesOrderConfirmSuccess extends SalesOrderState {
  final int orderId;

  SalesOrderConfirmSuccess(this.orderId);
}

class SalesOrderError extends SalesOrderState {
  final String message;

  SalesOrderError(this.message);
}

class SalesOrderCubit extends Cubit<SalesOrderState> {
  final SalesOrderRepository _repository;
  List<SalesOrderModel> _orders = [];

  SalesOrderCubit(this._repository) : super(SalesOrderInitial());

  // جلب قائمة أوامر البيع
  Future<void> fetchSalesOrders() async {
    emit(SalesOrderLoading());
    try {
      _orders = await _repository.getSalesOrders();
      emit(SalesOrderLoaded(_orders));
    } catch (e) {
      emit(SalesOrderError(e.toString()));
    }
  }

  // جلب تفاصيل طلب محدد وإصدار حالة التفاصيل
  Future<void> fetchOrderDetails(SalesOrderModel order) async {
    emit(SalesOrderLoading());
    try {
      final lines = await _repository.getSalesOrderLines(order.id);
      final updatedOrder = order.copyWith(orderLines: lines);
      emit(SalesOrderDetailLoaded(updatedOrder));
    } catch (e) {
      emit(SalesOrderError("فشل تحميل تفاصيل المنتجات: ${e.toString()}"));
    }
  }

  // تأكيد أمر البيع (تحويله من draft -> sale)
  Future<void> confirmOrder(int orderId) async {
    emit(SalesOrderConfirming());
    try {
      final success = await _repository.confirmSalesOrder(orderId);
      if (success) {
        emit(SalesOrderConfirmSuccess(orderId));
        // إعادة تحديث القائمة بعد التأكيد
        await fetchSalesOrders();
      } else {
        emit(SalesOrderError("لم يتسنّ تأكيد الطلب، تحقق من صلاحياتك"));
      }
    } catch (e) {
      emit(SalesOrderError(e.toString()));
    }
  }
}
