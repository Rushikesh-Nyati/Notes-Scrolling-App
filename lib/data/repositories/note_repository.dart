import '../models/note_model.dart';
// import '../models/tag_model.dart';
import '../services/local_database_service.dart';

class NoteRepository {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  Future<int> createNote(NoteModel note) async {
    return await _dbService.insertNote(note);
  }

  Future<List<NoteModel>> getAllNotes() async {
    return await _dbService.getAllNotes();
  }

  Future<NoteModel?> getNoteById(int noteId) async {
    final notes = await _dbService.getAllNotes();
    try {
      return notes.firstWhere((note) => note.id == noteId);
    } catch (e) {
      return null;
    }
  }

  Future<int> updateNote(NoteModel note) async {
    return await _dbService.updateNote(note);
  }

  Future<int> deleteNote(int noteId) async {
    return await _dbService.deleteNote(noteId);
  }

  Future<int> connectNotes(int sourceId, int targetId) async {
    return await _dbService.connectNotes(sourceId, targetId);
  }

  Future<List<NoteModel>> searchByTag({
    String? subject,
    String? chapter,
    String? topic,
  }) async {
    return await _dbService.searchNotesByTag(
      subject: subject,
      chapter: chapter,
      topic: topic,
    );
  }

  Future<List<NoteModel>> getConnectedNotes(int noteId) async {
    final note = await getNoteById(noteId);
    if (note == null || note.connectedNoteIds.isEmpty) return [];

    final allNotes = await getAllNotes();
    return allNotes.where((n) => note.connectedNoteIds.contains(n.id)).toList();
  }
}
