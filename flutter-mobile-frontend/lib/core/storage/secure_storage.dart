import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _accessTokenKey  = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _userIdKey       = 'userId';
  static const _usernameKey     = 'username';

  /* ── Access Token ── */
  static Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  static Future<String?> getAccessToken() =>
      _storage.read(key: _accessTokenKey);

  static Future<void> deleteAccessToken() =>
      _storage.delete(key: _accessTokenKey);

  /* ── Refresh Token ── */
  static Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  static Future<void> deleteRefreshToken() =>
      _storage.delete(key: _refreshTokenKey);

  /* ── User Info ── */
  static Future<void> saveUser({
    required String id,
    required String username,
  }) async {
    await _storage.write(key: _userIdKey, value: id);
    await _storage.write(key: _usernameKey, value: username);
  }

  static Future<Map<String, String?>> getUser() async {
    final id       = await _storage.read(key: _userIdKey);
    final username = await _storage.read(key: _usernameKey);
    return { 'id': id, 'username': username };
  }

  /* ── Clear all on logout ── */
  static Future<void> clearAll() => _storage.deleteAll();
}