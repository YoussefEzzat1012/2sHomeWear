import 'package:bloc/bloc.dart';

import '../data/models/customer_model.dart';
import '../data/repositories/customer_repository.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final List<CustomerModel> filteredCustomers;
  final bool isOffline;

  CustomerLoaded({
    required this.customers,
    required this.filteredCustomers,
    this.isOffline = false,
  });
}

class CustomerError extends CustomerState {
  final String message;

  CustomerError(this.message);
}

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _repository;
  List<CustomerModel> _allCustomers = [];

  CustomerCubit(this._repository) : super(CustomerInitial());

  Future<void> fetchCustomers({required bool isOnline}) async {
    emit(CustomerLoading());
    try {
      _allCustomers = await _repository.getCustomers(isOnline: isOnline);
      emit(CustomerLoaded(
        customers: _allCustomers,
        filteredCustomers: _allCustomers,
        isOffline: !isOnline,
      ));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  // البحث عن عميل حسب الاسم
  void searchCustomer(String query) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      if (query.isEmpty) {
        emit(CustomerLoaded(
          customers: _allCustomers,
          filteredCustomers: _allCustomers,
          isOffline: currentState.isOffline,
        ));
      } else {
        final filtered = _allCustomers
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        emit(CustomerLoaded(
          customers: _allCustomers,
          filteredCustomers: filtered,
          isOffline: currentState.isOffline,
        ));
      }
    }
  }

  // تحديث رقم الهاتف
  Future<void> updatePhone({
    required int partnerId,
    required String newPhone,
    required bool isOnline,
  }) async {
    try {
      await _repository.updateCustomerPhone(
        partnerId: partnerId,
        newPhone: newPhone,
        isOnline: isOnline,
      );
      // إعادة تحميل القائمة لتطوير البيانات محلياً
      await fetchCustomers(isOnline: isOnline);
    } catch (e) {
      emit(CustomerError("فشل تحديث رقم الهاتف"));
    }
  }
}
