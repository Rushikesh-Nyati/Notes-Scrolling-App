import 'dart:math';
import '../models/note_model.dart';

class RandomScrollService {
  final List<int> _viewedNoteIds = [];
  List<int> _availableNoteIds = [];
  final Random _random = Random();

  void initializeNotes(List<NoteModel> notes) {
    _availableNoteIds = notes.map((note) => note.id!).toList();
    _viewedNoteIds.clear();
  }

  NoteModel? getNextRandomNote(List<NoteModel> allNotes) {
    if (allNotes.isEmpty) return null;

    // Reset if all notes have been viewed
    if (_viewedNoteIds.length >= allNotes.length) {
      _viewedNoteIds.clear();
    }

    // Get unviewed notes
    List<NoteModel> unviewedNotes =
        allNotes.where((note) => !_viewedNoteIds.contains(note.id)).toList();

    if (unviewedNotes.isEmpty) {
      unviewedNotes = allNotes;
      _viewedNoteIds.clear();
    }

    // Pick random note
    final int randomIndex = _random.nextInt(unviewedNotes.length);
    final NoteModel selectedNote = unviewedNotes[randomIndex];
    _viewedNoteIds.add(selectedNote.id!);

    return selectedNote;
  }

  void resetViewed() {
    _viewedNoteIds.clear();
  }

  int get viewedCount => _viewedNoteIds.length;
  int get totalCount => _availableNoteIds.length;
}
