import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user.dart';

class AuthService {
  final _dio = ApiClient.instance;

  /* ── Register ── */
  Future<void> register({
    required String username,
    required String password,
  }) async {
    await _dio.post(
      '/auth/register',
      data: {'username': username, 'password': password},
    );
  }

  /* ── Login ── */
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    final accessToken  = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    /* ── Save tokens and user ── */
    await SecureStorage.saveAccessToken(accessToken);
    await SecureStorage.saveRefreshToken(refreshToken);
    await SecureStorage.saveUser(id: user.id, username: user.username);

    return user;
  }

  /* ── Logout ── */
  Future<void> logout() async {
    await _dio.post('/auth/logout');
    await SecureStorage.clearAll();
  }

  /* ── Restore session on app launch ── */
  Future<User?> restoreSession() async {
    final userData = await SecureStorage.getUser();
    final id       = userData['id'];
    final username = userData['username'];

    if (id == null || username == null) return null;

    return User(id: id, username: username);
  }
}