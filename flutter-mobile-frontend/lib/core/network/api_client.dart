import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static Dio? _instance;

  static const String baseUrl = 'http://your-ip:5000/api';

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    /* ── Request interceptor — attach access token ── */
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getAccessToken();
          print('🔵 Token exists: ${token != null}');
          print('🔵 Request URL: ${options.path}');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        /* ── Response interceptor — handle 401, refresh token ── */
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // try to refresh the token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // retry the original request with new token
              final token = await SecureStorage.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  /* ── Refresh token logic ── */
  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '$baseUrl/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String;
      await SecureStorage.saveAccessToken(newAccessToken);
      return true;
    } catch (_) {
      await SecureStorage.clearAll();
      return false;
    }
  }
}
