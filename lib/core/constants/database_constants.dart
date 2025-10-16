class DatabaseConstants {
  static const String databaseName = 'notes_database.db';
  static const int databaseVersion = 1;

  // Notes table
  static const String tableNotes = 'notes';
  static const String columnNoteId = 'id';
  static const String columnImagePath = 'image_path';
  static const String columnNoteText = 'note_text';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Tags table
  static const String tableTags = 'tags';
  static const String columnTagId = 'tag_id';
  static const String columnNoteIdFk = 'note_id';
  static const String columnSubject = 'subject';
  static const String columnChapter = 'chapter';
  static const String columnTopic = 'topic';

  // Connected notes table (for linking related notes)
  static const String tableConnectedNotes = 'connected_notes';
  static const String columnConnectionId = 'connection_id';
  static const String columnSourceNoteId = 'source_note_id';
  static const String columnTargetNoteId = 'target_note_id';
}
