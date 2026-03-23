import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/note_service.dart';
import '../models/note.dart';
import 'notes_state.dart';

final noteServiceProvider = Provider<NoteService>((ref) => NoteService());

final notesProvider = NotifierProvider<NotesNotifier, NotesState>(
  NotesNotifier.new,
);

class NotesNotifier extends Notifier<NotesState> {
  late final NoteService _noteService;
  Note? _deletedNote;
  Timer? _deleteTimer;

  @override
  NotesState build() {
    _noteService = ref.read(noteServiceProvider);
    Future.microtask(() => fetchNotes());
    return const NotesState();
  }

  /* ── Fetch notes (first page) ── */
  Future<void> fetchNotes({String? search}) async {
    state = state.copyWith(
      status: NotesStatus.loading,
      currentPage: 1,
      search: search ?? state.search,
      error: null,
    );

    try {
      final result = await _noteService.getNotes(
        page: 1,
        search: search ?? state.search,
      );

      state = state.copyWith(
        status: NotesStatus.success,
        notes: result.notes,
        currentPage: result.page,
        totalPages: result.pages,
        hasMore: result.page < result.pages,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: NotesStatus.error,
        error: _extractError(e, 'Failed to load notes'),
      );
    }
  }

  /* ── Load next page (infinite scroll) ── */
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = state.currentPage + 1;

    try {
      final result = await _noteService.getNotes(
        page: nextPage,
        search: state.search,
      );

      state = state.copyWith(
        notes: [...state.notes, ...result.notes],
        currentPage: result.page,
        totalPages: result.pages,
        hasMore: result.page < result.pages,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        error: _extractError(e, 'Failed to load more notes'),
      );
    }
  }

  /* ── Search ── */
  Future<void> searchNotes(String query) async {
    await fetchNotes(search: query);
  }

  /* ── Create note ── */
  Future<bool> createNote({
    required String title,
    required String content,
  }) async {
    try {
      final note = await _noteService.createNote(
        title: title,
        content: content,
      );
      state = state.copyWith(notes: [note, ...state.notes]);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        error: _extractError(e, 'Failed to create note'),
      );
      return false;
    }
  }

  /* ── Update note ── */
  Future<bool> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    try {
      final updated = await _noteService.updateNote(
        id: id,
        title: title,
        content: content,
      );
      state = state.copyWith(
        notes: state.notes.map((n) => n.id == id ? updated : n).toList(),
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        error: _extractError(e, 'Failed to update note'),
      );
      return false;
    }
  }

  /* ── Soft delete with undo ── */
  Future<void> deleteNote(String id) async {
    // cancel any pending delete
    _deleteTimer?.cancel();

    // store note before removing
    _deletedNote = state.notes.firstWhere(
      (n) => n.id == id,
      orElse: () => state.notes.first,
    );

    // optimistically remove from UI
    state = state.copyWith(
      notes: state.notes.where((n) => n.id != id).toList(),
    );

    // actually delete after 4 seconds
    _deleteTimer = Timer(const Duration(seconds: 4), () async {
      try {
        await _noteService.deleteNote(id);
      } on DioException catch (_) {
        // if delete fails — refetch to restore
        await fetchNotes();
      }
      _deletedNote = null;
      _deleteTimer = null;
    });
  }

  /* ── Undo delete ── */
  void undoDelete() {
    _deleteTimer?.cancel();
    _deleteTimer = null;

    if (_deletedNote != null) {
      state = state.copyWith(
        notes: [_deletedNote!, ...state.notes],
      );
      _deletedNote = null;
    }
  }

  /* ── Extract error message ── */
  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? fallback;
    }
    return fallback;
  }
}