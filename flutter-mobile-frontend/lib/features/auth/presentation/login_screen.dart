import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    await ref.read(authProvider.notifier).login(
      username: username,
      password: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final error     = authState.error;

    /* ── Navigate to notes on successful login ── */
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/notes');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /* ── Brand ── */
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Center(
                          child: Text(
                            'n',
                            style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppColors.cream,
                                fontStyle: FontStyle.italic,
                              ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Noteworthy',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  /* ── Heading ── */
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign in to continue to your notes.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  /* ── Error banner ── */
                  if (error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.redSoft.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.redSoft.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                            color: AppColors.redSoft, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              error,
                              style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.redSoft),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  /* ── Username field ── */
                  Text('USERNAME',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 11,
                      letterSpacing: 1,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Enter your username',
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  /* ── Password field ── */
                  Text('PASSWORD',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 11,
                      letterSpacing: 1,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                          color: AppColors.inkFaint,
                          size: 20,
                        ),
                        onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /* ── Submit button ── */
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.cream,
                            ),
                          )
                        : const Text('Sign In'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /* ── Register link ── */
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            'Create one',
                            style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.amber,
                                fontWeight: FontWeight.w600,
                              ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}