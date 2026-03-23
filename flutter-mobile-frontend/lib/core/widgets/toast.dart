import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppToast {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    VoidCallback? onUndo,
    String? undoLabel,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message:    message,
        isError:    isError,
        onUndo:     onUndo,
        undoLabel:  undoLabel ?? 'Undo',
        onDismiss:  () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback? onUndo;
  final String undoLabel;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.isError,
    required this.undoLabel,
    required this.onDismiss,
    this.onUndo,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1)
      .animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      left:   24,
      right:  24,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical:   AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color:        AppColors.ink,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color:      AppColors.ink.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset:     const Offset(0, 4),
                  ),
                ],
                border: Border(
                  left: BorderSide(
                    color: widget.isError ? AppColors.redSoft : Colors.green,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color:    AppColors.cream,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (widget.onUndo != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: () {
                        widget.onUndo!();
                        widget.onDismiss();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical:   4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.cream.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          widget.undoLabel,
                          style: const TextStyle(
                            color:      AppColors.cream,
                            fontSize:   12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}