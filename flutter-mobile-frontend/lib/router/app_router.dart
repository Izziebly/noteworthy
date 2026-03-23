import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/notes/presentation/notes_screen.dart';
import '../features/notes/presentation/create_note_screen.dart';
import '../features/notes/presentation/note_detail_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/providers/auth_state.dart';

class RiverpodRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RiverpodRouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RiverpodRouterNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier, // ← clean ChangeNotifier
    redirect: (context, state) {
      final authState   = ref.read(authProvider);
      final isLoading   = authState.status == AuthStatus.initial ||
                          authState.status == AuthStatus.loading;
      final isLoggedIn  = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
                          state.matchedLocation == '/register';

      if (isLoading)                   return null;
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute)   return '/notes';
      return null;
    },
    routes: [
      GoRoute(path: '/login',     builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register',  builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/notes',     builder: (_, _) => const NotesScreen()),
      GoRoute(path: '/notes/new', builder: (_, _) => const CreateNoteScreen()),
      GoRoute(
        path: '/notes/:id',
        builder: (_, state) => NoteDetailScreen(
          noteId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});