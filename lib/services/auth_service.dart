import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rapid_pass_info/services/rapid_pass.dart';

class AuthService {
  static final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      groupId: 'com.arafatamim.rapid_pass_info',
    ),
  );

  static const String _usernameKey = 'saved_username';
  static const String _passwordKey = 'saved_password';
  static const String _rememberMeKey = 'remember_me';
  static const String _sessionKey = 'user_session';

  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  // Check if user wants to be remembered
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  // Save remember me preference
  Future<void> setRememberMe(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, remember);
  }

  // Save credentials securely
  Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _passwordKey, value: password);
  }

  // Get saved credentials
  Future<Map<String, String?>> getSavedCredentials() async {
    final username = await _storage.read(key: _usernameKey);
    final password = await _storage.read(key: _passwordKey);
    return {'username': username, 'password': password};
  }

  // Clear saved credentials
  Future<void> clearCredentials() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
    await _storage.delete(key: _sessionKey);
    await setRememberMe(false);
  }

  // Save session (optional - for keeping user logged in)
  Future<void> saveSession(String session) async {
    await _storage.write(key: _sessionKey, value: session);
  }

  // Get saved session
  Future<String?> getSavedSession() async {
    return await _storage.read(key: _sessionKey);
  }

  // Check if user is logged in (has valid session)
  Future<bool> isLoggedIn() async {
    final session = await getSavedSession();
    return session != null && session.isNotEmpty;
  }

  // Auto login with saved credentials
  Future<AuthenticatedSession?> autoLogin() async {
    try {
      final credentials = await getSavedCredentials();
      final username = credentials['username'];
      final password = credentials['password'];

      if (username != null && password != null) {
        final session = await RapidPassService.instance.login(
          username: username,
          password: password,
        );
        return session;
      }
    } catch (e) {
      await clearCredentials();
    }
    return null;
  }
}
