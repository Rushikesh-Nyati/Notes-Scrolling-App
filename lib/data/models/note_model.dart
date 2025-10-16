import 'tag_model.dart';

class NoteModel {
  final int? id;
  final String imagePath;
  String noteText;
  final List<TagModel> tags;
  final List<int> connectedNoteIds;
  final DateTime createdAt;
  DateTime updatedAt;

  NoteModel({
    this.id,
    required this.imagePath,
    this.noteText = '',
    required this.tags,
    this.connectedNoteIds = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'note_text': noteText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(
      Map<String, dynamic> map, List<TagModel> tags, List<int> connectedIds) {
    return NoteModel(
      id: map['id'],
      imagePath: map['image_path'],
      noteText: map['note_text'] ?? '',
      tags: tags,
      connectedNoteIds: connectedIds,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
