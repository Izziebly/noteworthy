import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) return;
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    await ref.read(authProvider.notifier).register(
      username: username,
      password: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final error     = authState.error;

    /* ── Navigate to login on successful register ── */
    ref.listen(authProvider, (previous, next) {
      if (previous?.status == AuthStatus.loading &&
          next.status == AuthStatus.unauthenticated &&
          next.error == null) {
        context.go('/login');
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
                    'Create account',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Start writing and organising your notes.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  /* ── Error banner ── */
                  if (error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.redSoft.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.redSoft.withValues(alpha: .3)),
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
                      hintText: 'Choose a username',
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
                    onFieldSubmitted: (_) => _handleRegister(),
                    decoration: InputDecoration(
                      hintText: 'At least 6 characters',
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
                      onPressed: isLoading ? null : _handleRegister,
                      child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.cream,
                            ),
                          )
                        : const Text('Create Account'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  /* ── Login link ── */
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Sign in',
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