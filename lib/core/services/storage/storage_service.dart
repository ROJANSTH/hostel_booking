import 'package:hostel_booking/core/constants/app_constants.dart';
import 'package:hostel_booking/features/auth/data/models/auth_api_model.dart';
import 'package:hostel_booking/features/auth/domain/entities/auth_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.authTokenKey, token);
  }

  String? getToken() => _prefs.getString(AppConstants.authTokenKey);

  Future<void> saveUser(AuthUserModel user) async {
    await Future.wait([
      if (user.id != null)
        _prefs.setString(AppConstants.userIdKey, user.id!),
      _prefs.setString(AppConstants.userNameKey, user.fullName),
      _prefs.setString(AppConstants.userEmailKey, user.email),
      _prefs.setString(AppConstants.userPhoneKey, user.phoneNumber),
    ]);
  }

  AuthEntity? getSavedUser() {
    final email = _prefs.getString(AppConstants.userEmailKey);
    if (email == null || email.isEmpty) return null;

    return AuthEntity(
      id: _prefs.getString(AppConstants.userIdKey),
      name: _prefs.getString(AppConstants.userNameKey) ?? '',
      email: email,
      password: '',
      phone: _prefs.getString(AppConstants.userPhoneKey) ?? '',
    );
  }

  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await Future.wait([
      _prefs.remove(AppConstants.authTokenKey),
      _prefs.remove(AppConstants.userIdKey),
      _prefs.remove(AppConstants.userNameKey),
      _prefs.remove(AppConstants.userEmailKey),
      _prefs.remove(AppConstants.userPhoneKey),
    ]);
  }
}
