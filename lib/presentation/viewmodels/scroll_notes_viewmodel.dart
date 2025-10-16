import 'package:flutter/foundation.dart';
import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository.dart';
import '../../data/services/random_scroll_service.dart';

class ScrollNotesViewModel extends ChangeNotifier {
  final NoteRepository _noteRepository = NoteRepository();
  final RandomScrollService _scrollService = RandomScrollService();

  List<NoteModel> _allNotes = [];
  NoteModel? _currentNote;
  bool _isLoading = false;

  NoteModel? get currentNote => _currentNote;
  bool get isLoading => _isLoading;
  int get viewedCount => _scrollService.viewedCount;
  int get totalCount => _scrollService.totalCount;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allNotes = await _noteRepository.getAllNotes();
      _scrollService.initializeNotes(_allNotes);
      loadNextNote();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadNextNote() {
    _currentNote = _scrollService.getNextRandomNote(_allNotes);
    notifyListeners();
  }

  Future<void> updateNoteText(String text) async {
    if (_currentNote != null) {
      _currentNote!.noteText = text;
      await _noteRepository.updateNote(_currentNote!);
      notifyListeners();
    }
  }

  void resetScrolling() {
    _scrollService.resetViewed();
    loadNextNote();
  }
}
