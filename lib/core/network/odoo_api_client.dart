import 'package:dio/dio.dart';

class OdooApiClient {
  final Dio _dio;
  String? _sessionId;

  OdooApiClient({required String baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  // تسجيل الدخول لحفظ الجلسة
  Future<Map<String, dynamic>> authenticate({
    required String db,
    required String login,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/web/session/authenticate',
        data: {
          "jsonrpc": "2.0",
          "params": {
            "db": db,
            "login": login,
            "password": password,
          }
        },
      );

      final data = response.data;

      if (data['error'] != null) {
        throw Exception(
            data['error']['data']?['message'] ?? 'فشل تسجيل الدخول');
      }

      // استخراج الـ Session Cookie وحفظها للطلبات القادمة
      final cookies = response.headers['set-cookie'];
      if (cookies != null && cookies.isNotEmpty) {
        _sessionId = cookies.first.split(';').first;
        _dio.options.headers['Cookie'] = _sessionId;
      }

      return data['result'];
    } on DioException catch (e) {
      throw Exception('خطأ في الاتصال بالشبكة: ${e.message}');
    }
  }

  // دالة عامة لاستدعاء أساليب Odoo (call_kw)
  Future<dynamic> callKw({
    required String model,
    required String method,
    required List<dynamic> args,
    Map<String, dynamic>? kwargs,
  }) async {
    try {
      final response = await _dio.post(
        '/web/dataset/call_kw',
        data: {
          "jsonrpc": "2.0",
          "method": "call",
          "params": {
            "model": model,
            "method": method,
            "args": args,
            "kwargs": kwargs ?? {},
          }
        },
      );

      final data = response.data;

      if (data['error'] != null) {
        throw Exception(
            data['error']['data']?['message'] ?? 'حدث خطأ في Odoo API');
      }

      return data['result'];
    } on DioException catch (e) {
      throw Exception('خطأ في الاتصال: ${e.message}');
    }
  }
}
