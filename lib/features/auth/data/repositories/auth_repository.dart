import 'package:hive/hive.dart';

import '../../../../core/network/odoo_api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final OdooApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<UserModel> login({
    required String username,
    required String password,
    String db = '2s-home-wear',
  }) async {
    final result = await _apiClient.authenticate(
      db: db,
      login: username,
      password: password,
    );

    // Verify if the authenticated user has Internal User permissions
    final isInternal = await _checkIfInternalUser();

    return UserModel(
      uid: result['uid'],
      name: result['name'],
      username: result['username'],
      isInternalUser: isInternal,
    );
  }

  /// Checks if the current session has Internal User privileges
  /// by checking read access on Odoo sales orders.
  Future<bool> _checkIfInternalUser() async {
    try {
      final bool isInternal = await _apiClient.callKw(
        model: 'res.users',
        method: 'has_group',
        args: ['base.group_user'],
      );

      return isInternal;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final box = await Hive.openBox('auth_box');
    await box.clear();
  }
}
