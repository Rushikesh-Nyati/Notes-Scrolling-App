import 'package:flutter/foundation.dart';
import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final NoteRepository _noteRepository = NoteRepository();

  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNotes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notes = await _noteRepository.getAllNotes();
      _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _errorMessage = 'Failed to load notes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNote(int noteId) async {
    try {
      await _noteRepository.deleteNote(noteId);
      _notes.removeWhere((note) => note.id == noteId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete note: $e';
      notifyListeners();
    }
  }

  Future<List<NoteModel>> searchNotes({
    String? subject,
    String? chapter,
    String? topic,
  }) async {
    try {
      return await _noteRepository.searchByTag(
        subject: subject,
        chapter: chapter,
        topic: topic,
      );
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      notifyListeners();
      return [];
    }
  }
}
