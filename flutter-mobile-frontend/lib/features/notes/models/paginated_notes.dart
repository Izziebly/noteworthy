import 'note.dart';

class PaginatedNotes {
  final int total;
  final int page;
  final int pages;
  final List<Note> notes;

  const PaginatedNotes({
    required this.total,
    required this.page,
    required this.pages,
    required this.notes,
  });

  factory PaginatedNotes.fromJson(Map<String, dynamic> json) {
    final notesList = (json['notes'] as List<dynamic>)
        .map((n) => Note.fromJson(n as Map<String, dynamic>))
        .toList();

    return PaginatedNotes(
      total: json['total'] as int,
      page:  json['page']  as int,
      pages: json['pages'] as int,
      notes: notesList,
    );
  }
}