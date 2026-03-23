import '../../../core/network/api_client.dart';
import '../models/note.dart';
import '../models/paginated_notes.dart';

class NoteService {
  final _dio = ApiClient.instance;

  /* ── GET all notes (paginated + search) ── */
  Future<PaginatedNotes> getNotes({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    final response = await _dio.get(
      '/notes',
      queryParameters: {
        'page':   page,
        'limit':  limit,
        if (search.isNotEmpty) 'search': search,
      },
    );
    return PaginatedNotes.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /* ── GET single note by ID ── */
  Future<Note> getNoteById(String id) async {
    final response = await _dio.get('/notes/$id');
    return Note.fromJson(response.data as Map<String, dynamic>);
  }

  /* ── POST create note ── */
  Future<Note> createNote({
    required String title,
    required String content,
  }) async {
    final response = await _dio.post(
      '/notes',
      data: {'title': title, 'content': content},
    );
    return Note.fromJson(response.data as Map<String, dynamic>);
  }

  /* ── PUT update note ── */
  Future<Note> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final response = await _dio.put(
      '/notes/$id',
      data: {'title': title, 'content': content},
    );
    return Note.fromJson(response.data as Map<String, dynamic>);
  }

  /* ── DELETE note ── */
  Future<void> deleteNote(String id) async {
    await _dio.delete('/notes/$id');
  }
}