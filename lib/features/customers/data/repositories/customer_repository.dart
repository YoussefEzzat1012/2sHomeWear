import 'package:hive/hive.dart';

import '../../../../core/database/pending_sync_queue.dart';
import '../../../../core/network/odoo_api_client.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final OdooApiClient _apiClient;
  static const String customerBoxName = 'customers_cache';

  CustomerRepository(this._apiClient);

  // جلب العملاء مع دعم الـ Caching والـ Offline Fallback
  Future<List<CustomerModel>> getCustomers({bool isOnline = true}) async {
    final box = await Hive.openBox<CustomerModel>(customerBoxName);

    if (isOnline) {
      try {
        final List result = await _apiClient.callKw(
          model: 'res.partner',
          method: 'search_read',
          args: [],
          kwargs: {
            'domain': [
              ['customer_rank', '>', 0]
            ],
            'fields': ['id', 'name', 'phone', 'email', 'city'],
          },
        );

        final customers = result.map((e) => CustomerModel.fromJson(e)).toList();

        // تحديث التخزين المحلي
        await box.clear();
        for (var customer in customers) {
          await box.put(customer.id, customer);
        }

        // إطلاق عملية المزامنة للتعديلات المعلقة إن وجدت
        _syncPendingUpdates();

        return customers;
      } catch (e) {
        // في حال فشل الطلب بالرغم من وجود اتصال، نرجع البيانات المخزنة
        return box.values.toList();
      }
    } else {
      // إرجاع البيانات من الكاش المحلي مباشرة
      return box.values.toList();
    }
  }

  // تحديث رقم هاتف العميل
  Future<bool> updateCustomerPhone({
    required int partnerId,
    required String newPhone,
    required bool isOnline,
  }) async {
    final box = await Hive.openBox<CustomerModel>(customerBoxName);

    // 1. تحديث التخزين المحلي فوراً (Optimistic UI Update)
    final cachedCustomer = box.get(partnerId);
    if (cachedCustomer != null) {
      final updatedCustomer = cachedCustomer.copyWith(phone: newPhone);
      await box.put(partnerId, updatedCustomer);
    }

    if (isOnline) {
      try {
        final bool success = await _apiClient.callKw(
          model: 'res.partner',
          method: 'write',
          args: [
            [partnerId],
            {'phone': newPhone}
          ],
        );
        return success;
      } catch (e) {
        // إذا فشل الطلب بالرغم من الاتصال، نضعها في الانتظار للمزامنة لاحقاً
        await PendingSyncQueue.addPendingUpdate(partnerId, newPhone);
        return false;
      }
    } else {
      // حالة Offline: حفظ التعديل في قائمة الانتظار Sync Queue
      await PendingSyncQueue.addPendingUpdate(partnerId, newPhone);
      return true;
    }
  }

  // مزامنة التعديلات المعلقة فور عودة الاتصال بالإنترنت
  Future<void> _syncPendingUpdates() async {
    final pendingUpdates = await PendingSyncQueue.getPendingUpdates();
    if (pendingUpdates.isEmpty) return;

    for (var entry in pendingUpdates.entries) {
      final int partnerId = int.parse(entry.key.toString());
      final String phone = entry.value;

      try {
        final bool success = await _apiClient.callKw(
          model: 'res.partner',
          method: 'write',
          args: [
            [partnerId],
            {'phone': phone}
          ],
        );
        if (success) {
          await PendingSyncQueue.removePendingUpdate(partnerId);
        }
      } catch (_) {
        // الاستمرار ومحاولة المزامنة في المرة القادمة
      }
    }
  }
}
