import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notes_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/toast.dart';

class CreateNoteScreen extends ConsumerStatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  ConsumerState<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends ConsumerState<CreateNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  bool get _isReady =>
      _titleController.text.trim().isNotEmpty &&
      _contentController.text.trim().isNotEmpty;

  Future<void> _handleSave() async {
    if (!_isReady) return;

    setState(() => _isSaving = true);

    final success = await ref
        .read(notesProvider.notifier)
        .createNote(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        context.pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            AppToast.show(context, 'Note saved successfully');
          }
        });
      } else {
        AppToast.show(
          context,
          'Failed to save note. Please try again.',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.pop(),
          child: Text(
            '← Notes',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
          ),
        ),
        leadingWidth: 100,
        title: Text(
          'New Note',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Discard',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ElevatedButton(
              onPressed: (_isSaving || !_isReady) ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.cream,
                      ),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyS &&
              (HardwareKeyboard.instance.isControlPressed ||
                  HardwareKeyboard.instance.isMetaPressed)) {
            _handleSave();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              /* ── Editor card ── */
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      /* ── Title input ── */
                      TextField(
                        controller: _titleController,
                        maxLength: 120,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        style: Theme.of(context).textTheme.displayMedium,
                        decoration: InputDecoration(
                          hintText: 'Note title...',
                          hintStyle: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: AppColors.inkFaint,
                                fontStyle: FontStyle.italic,
                              ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          counterText: '',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),

                      const Divider(color: AppColors.borderSoft),
                      const SizedBox(height: AppSpacing.sm),

                      /* ── Content input ── */
                      Expanded(
                        child: TextField(
                          controller: _contentController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'Start writing...',
                            hintStyle: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.inkFaint),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /* ── Footer ── */
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_wordCount ${_wordCount == 1 ? 'word' : 'words'} · '
                      '${_contentController.text.length} characters',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    ElevatedButton(
                      onPressed: (_isSaving || !_isReady) ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amber,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('✓ Save Note'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
