import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notes_provider.dart';
import '../models/note.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/toast.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final String noteId;
  const NoteDetailScreen({super.key, required this.noteId});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  final _titleController   = TextEditingController();
  final _contentController = TextEditingController();
  bool _isEditing  = false;
  bool _isSaving   = false;
  bool _isLoading  = false;
  String? _error;
  Note? _note;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /* ── Try cache first, fetch from API if not found ── */
  void _loadNote() {
    final notes = ref.read(notesProvider).notes;
    final note  = notes.where((n) => n.id == widget.noteId).firstOrNull;

    if (note != null) {
      setState(() => _note = note);
    } else {
      _fetchNote();
    }
  }

  /* ── Fetch from API if not in cache ── */
  Future<void> _fetchNote() async {
    setState(() {
      _isLoading = true;
      _error     = null;
    });
    try {
      final note = await ref
          .read(noteServiceProvider)
          .getNoteById(widget.noteId);
      setState(() {
        _note      = note;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error     = 'Note not found or failed to load.';
        _isLoading = false;
      });
    }
  }

  void _startEditing() {
    if (_note == null) return;
    _titleController.text   = _note!.title;
    _contentController.text = _note!.content;
    setState(() => _isEditing = true);
  }

  void _discardEditing() {
    _titleController.clear();
    _contentController.clear();
    setState(() => _isEditing = false);
  }

  Future<void> _handleSave() async {
    final title   = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty || _note == null) return;

    setState(() => _isSaving = true);

    final success = await ref.read(notesProvider.notifier).updateNote(
      id:      _note!.id,
      title:   title,
      content: content,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        setState(() {
          _note      = _note!.copyWith(title: title, content: content);
          _isEditing = false;
        });
        AppToast.show(context, 'Changes saved successfully');
      } else {
        AppToast.show(
          context,
          'Failed to save changes. Please try again.',
          isError: true,
        );
      }
    }
  }

  int get _wordCount {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    const days   = ['Monday','Tuesday','Wednesday','Thursday',
                     'Friday','Saturday','Sunday'];
    const months = ['','January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return '${days[date.weekday - 1]}, ${months[date.month]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {

    /* ── Loading ── */
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.amber),
        ),
      );
    }

    /* ── Error ── */
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          leading: TextButton(
            onPressed: () => context.pop(),
            child: Text(
              '← Notes',
              style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.inkMuted),
            ),
          ),
          leadingWidth: 100,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                  color: AppColors.redSoft, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: _fetchNote,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    /* ── Note not loaded yet ── */
    if (_note == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.amber),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.pop(),
          child: Text(
            '← Notes',
            style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.inkMuted),
          ),
        ),
        leadingWidth: 100,
        title: _isEditing
          ? Text(
              'Editing',
              style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.inkSoft),
            )
          : const SizedBox.shrink(),
        actions: _isEditing
          ? [
              TextButton(
                onPressed: _discardEditing,
                child: Text(
                  'Discard',
                  style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.inkMuted),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.cream,
                        ),
                      )
                    : const Text('Save'),
                ),
              ),
            ]
          : [
              TextButton(
                onPressed: _startEditing,
                child: Text(
                  '✏️ Edit',
                  style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.inkSoft),
                ),
              ),
            ],
      ),
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (_isEditing && event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyS &&
              (HardwareKeyboard.instance.isControlPressed ||
               HardwareKeyboard.instance.isMetaPressed)) {
            _handleSave();
          }
          if (_isEditing && event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            _discardEditing();
          }
        },
        child: _isEditing
          ? _buildEditMode(context)
          : _buildReadMode(context),
      ),
    );
  }

  /* ── Read mode ── */
  Widget _buildReadMode(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(_note!.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.amberGlow.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: AppColors.amber.withValues(alpha: .3)),
            ),
            child: Text(
              'NOTE',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.amber,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _note!.title,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            height: 3,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.amber,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Text(
            _note!.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.85,
            ),
          ),
        ],
      ),
    );
  }

  /* ── Edit mode ── */
  Widget _buildEditMode(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: .08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    maxLength: 120,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    style: Theme.of(context).textTheme.displayMedium,
                    decoration: const InputDecoration(
                      border:        InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      counterText:   '',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const Divider(color: AppColors.borderSoft),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        border:        InputBorder.none,
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_wordCount words · '
                  '${_contentController.text.length} characters · ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amber,
                  ),
                  child: _isSaving
                    ? const SizedBox(
                        width: 10, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('✓ Save Changes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}