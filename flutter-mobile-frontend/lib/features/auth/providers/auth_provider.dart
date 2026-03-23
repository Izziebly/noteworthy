// lib/features/auth/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/auth_service.dart';
import 'auth_state.dart';

/* ── AuthService provider ── */
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/* ── Auth provider */
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.read(authServiceProvider);
    _restoreSession();
    return const AuthState();
  }

  /* ── Restore session on app launch ── */
  Future<void> _restoreSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.restoreSession();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /* ── Register ── */
  Future<void> register({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _authService.register(username: username, password: password);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } on DioException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _extractError(e, 'Registration failed'),
      );
    }
  }

  /* ── Login ── */
  // Future<void> login({
  //   required String username,
  //   required String password,
  // }) async {
  //   state = state.copyWith(status: AuthStatus.loading, error: null);
  //   try {
  //     final user = await _authService.login(
  //       username: username,
  //       password: password,
  //     );
  //     state = state.copyWith(
  //       status: AuthStatus.authenticated,
  //       user: user,
  //     );
  //   } on DioException catch (e) {
  //     state = state.copyWith(
  //       status: AuthStatus.unauthenticated,
  //       error: _extractError(e, 'Login failed'),
  //     );
  //   }
  // }
  
  Future<void> login({
  required String username,
  required String password,
}) async {
  state = state.copyWith(status: AuthStatus.loading, error: null);
  try {
    final user = await _authService.login(
      username: username,
      password: password,
    );
    print('✅ Login success — user: ${user.username}');
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
    );
  } on DioException catch (e) {
    print('❌ Login failed: ${e.message}');
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      error: _extractError(e, 'Login failed'),
    );
  }
}

  /* ── Logout ── */
  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /* ── Clear error ── */
  void clearError() {
    state = state.copyWith(error: null);
  }

  /* ── Extract error message from DioException ── */
  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? fallback;
    }
    return fallback;
  }
}