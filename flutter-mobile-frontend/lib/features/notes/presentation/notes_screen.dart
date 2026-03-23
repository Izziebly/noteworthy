import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notes_provider.dart';
import '../providers/notes_state.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/toast.dart';
import '../widgets/note_card.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showBackToTop = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    /* ── Infinite scroll trigger ── */
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notesProvider.notifier).loadMore();
    }

    /* ── Back to top button ── */
    setState(() {
      _showBackToTop = _scrollController.position.pixels > 400;
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(notesProvider.notifier).searchNotes(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);
    final authState  = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,

      /* ── Navbar ── */
      appBar: AppBar(
        title: const Text('Noteworthy'),
        actions: [
          if (authState.user != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Center(
                child: Text(
                  '@${authState.user!.username}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            ),
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
            child: Text(
              'Logout',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.redSoft,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /* ── Header ── */
                Text(
                  'Your workspace',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.amber,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.displayLarge,
                    children: [
                      TextSpan(
                        text: 'All Notes',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${notesState.notes.length} '
                  '${notesState.notes.length == 1 ? 'note' : 'notes'} saved',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: AppSpacing.md),

                /* ── Search bar ── */
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.inkFaint,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                            color: AppColors.inkFaint, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(notesProvider.notifier).fetchNotes(search: '');
                          },
                        )
                      : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(99),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(99),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(99),
                      borderSide: const BorderSide(
                        color: AppColors.amber, width: 1.5),
                    ),
                  ),
                ),

              ],
            ),
          ),

          /* ── Notes list ── */
          Expanded(
            child: RefreshIndicator(
              color: AppColors.amber,
              onRefresh: () => ref.read(notesProvider.notifier).fetchNotes(),
              child: _buildBody(context, notesState),
            ),
          ),

        ],
      ),

      /* ── FABs ── */
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          /* ── Back to top ── */
          if (_showBackToTop) ...[
            FloatingActionButton.small(
              heroTag: 'backToTop',
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              ),
              backgroundColor: AppColors.paper,
              foregroundColor: AppColors.ink,
              child: const Icon(Icons.keyboard_arrow_up),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          /* ── New note ── */
          FloatingActionButton(
            heroTag: 'newNote',
            onPressed: () => context.push('/notes/new'),
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.cream,
            child: const Icon(Icons.add, size: 28),
          ),

        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotesState notesState) {

    /* ── Loading first page ── */
    if (notesState.status == NotesStatus.loading &&
        notesState.notes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.amber),
      );
    }

    /* ── Error ── */
    if (notesState.status == NotesStatus.error &&
        notesState.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
              color: AppColors.redSoft, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              notesState.error ?? 'Failed to load notes',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () =>
                ref.read(notesProvider.notifier).fetchNotes(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    /* ── Empty state ── */
    if (notesState.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📝', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              _searchController.text.isNotEmpty
                ? 'No results found'
                : 'No notes yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                _searchController.text.isNotEmpty
                  ? 'Nothing matched "${_searchController.text}". Try a different search.'
                  : 'Tap the + button below to write your first note.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  ref.read(notesProvider.notifier).fetchNotes(search: '');
                },
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      );
    }

    /* ── Notes grid ── */
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, 0, AppSpacing.lg, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 12,
        mainAxisSpacing:  12,
        childAspectRatio: 0.85,
      ),
      itemCount: notesState.notes.length + (notesState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {

        /* ── Loading indicator at bottom ── */
        if (index == notesState.notes.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(color: AppColors.amber),
            ),
          );
        }

        final note = notesState.notes[index];
        return NoteCard(
          note:  note,
          onTap: () => context.push('/notes/${note.id}'),
          onDelete: () {
            ref.read(notesProvider.notifier).deleteNote(note.id);
            AppToast.show(
              context,
              'Note deleted',
              onUndo: () =>
                ref.read(notesProvider.notifier).undoDelete(),
            );
          },
        );
      },
    );
  }
}