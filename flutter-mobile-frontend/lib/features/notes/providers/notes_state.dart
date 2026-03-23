import '../models/note.dart';

enum NotesStatus { initial, loading, success, error }

class NotesState {
  final NotesStatus status;
  final List<Note> notes;
  final String search;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final String? error;

  const NotesState({
    this.status      = NotesStatus.initial,
    this.notes       = const [],
    this.search      = '',
    this.currentPage = 1,
    this.totalPages  = 1,
    this.hasMore     = false,
    this.error,
  });

  bool get isLoading  => status == NotesStatus.loading;
  bool get isSuccess  => status == NotesStatus.success;

  NotesState copyWith({
    NotesStatus? status,
    List<Note>? notes,
    String? search,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    String? error,
  }) {
    return NotesState(
      status:      status      ?? this.status,
      notes:       notes       ?? this.notes,
      search:      search      ?? this.search,
      currentPage: currentPage ?? this.currentPage,
      totalPages:  totalPages  ?? this.totalPages,
      hasMore:     hasMore     ?? this.hasMore,
      error:       error       ?? this.error,
    );
  }
}