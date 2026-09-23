import 'package:hive/hive.dart';

class PendingSyncQueue {
  static const String boxName = 'pending_phone_updates';

  // حفظ التعديل المعلق محلياً
  static Future<void> addPendingUpdate(int partnerId, String newPhone) async {
    final box = await Hive.openBox<String>(boxName);
    await box.put(partnerId.toString(), newPhone);
  }

  // جلب كافة التعديلات المعلقة
  static Future<Map<dynamic, String>> getPendingUpdates() async {
    final box = await Hive.openBox<String>(boxName);
    return box.toMap().cast<dynamic, String>();
  }

  // مسح التعديل بعد نجاح المزامنة مع Odoo
  static Future<void> removePendingUpdate(int partnerId) async {
    final box = await Hive.openBox<String>(boxName);
    await box.delete(partnerId.toString());
  }
}
