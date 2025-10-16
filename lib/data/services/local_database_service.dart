import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/database_constants.dart';
import '../models/note_model.dart';
import '../models/tag_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path =
        join(await getDatabasesPath(), DatabaseConstants.databaseName);
    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Notes table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableNotes} (
        ${DatabaseConstants.columnNoteId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.columnImagePath} TEXT NOT NULL,
        ${DatabaseConstants.columnNoteText} TEXT,
        ${DatabaseConstants.columnCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.columnUpdatedAt} TEXT NOT NULL
      )
    ''');

    // Tags table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableTags} (
        ${DatabaseConstants.columnTagId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.columnNoteIdFk} INTEGER NOT NULL,
        ${DatabaseConstants.columnSubject} TEXT NOT NULL,
        ${DatabaseConstants.columnChapter} TEXT,
        ${DatabaseConstants.columnTopic} TEXT,
        FOREIGN KEY (${DatabaseConstants.columnNoteIdFk}) 
          REFERENCES ${DatabaseConstants.tableNotes} (${DatabaseConstants.columnNoteId})
          ON DELETE CASCADE
      )
    ''');

    // Connected notes table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableConnectedNotes} (
        ${DatabaseConstants.columnConnectionId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.columnSourceNoteId} INTEGER NOT NULL,
        ${DatabaseConstants.columnTargetNoteId} INTEGER NOT NULL,
        FOREIGN KEY (${DatabaseConstants.columnSourceNoteId}) 
          REFERENCES ${DatabaseConstants.tableNotes} (${DatabaseConstants.columnNoteId})
          ON DELETE CASCADE,
        FOREIGN KEY (${DatabaseConstants.columnTargetNoteId}) 
          REFERENCES ${DatabaseConstants.tableNotes} (${DatabaseConstants.columnNoteId})
          ON DELETE CASCADE
      )
    ''');
  }

  // Insert note with tags
  Future<int> insertNote(NoteModel note) async {
    final db = await database;
    int noteId = await db.insert(DatabaseConstants.tableNotes, note.toMap());

    // Insert tags
    for (var tag in note.tags) {
      await db.insert(DatabaseConstants.tableTags, {
        ...tag.toMap(),
        DatabaseConstants.columnNoteIdFk: noteId,
      });
    }

    return noteId;
  }

  // Get all notes with tags and connections
  Future<List<NoteModel>> getAllNotes() async {
    final db = await database;
    final notesData = await db.query(DatabaseConstants.tableNotes);

    List<NoteModel> notes = [];
    for (var noteMap in notesData) {
      int noteId = noteMap[DatabaseConstants.columnNoteId] as int;

      // Get tags for this note
      final tagsData = await db.query(
        DatabaseConstants.tableTags,
        where: '${DatabaseConstants.columnNoteIdFk} = ?',
        whereArgs: [noteId],
      );
      List<TagModel> tags = tagsData.map((e) => TagModel.fromMap(e)).toList();

      // Get connected note IDs
      final connectionsData = await db.query(
        DatabaseConstants.tableConnectedNotes,
        where: '${DatabaseConstants.columnSourceNoteId} = ?',
        whereArgs: [noteId],
      );
      List<int> connectedIds = connectionsData
          .map((e) => e[DatabaseConstants.columnTargetNoteId] as int)
          .toList();

      notes.add(NoteModel.fromMap(noteMap, tags, connectedIds));
    }

    return notes;
  }

  // Update note
  Future<int> updateNote(NoteModel note) async {
    final db = await database;
    note.updatedAt = DateTime.now();
    return await db.update(
      DatabaseConstants.tableNotes,
      note.toMap(),
      where: '${DatabaseConstants.columnNoteId} = ?',
      whereArgs: [note.id],
    );
  }

  // Delete note
  Future<int> deleteNote(int noteId) async {
    final db = await database;
    return await db.delete(
      DatabaseConstants.tableNotes,
      where: '${DatabaseConstants.columnNoteId} = ?',
      whereArgs: [noteId],
    );
  }

  // Connect two notes
  Future<int> connectNotes(int sourceNoteId, int targetNoteId) async {
    final db = await database;
    return await db.insert(DatabaseConstants.tableConnectedNotes, {
      DatabaseConstants.columnSourceNoteId: sourceNoteId,
      DatabaseConstants.columnTargetNoteId: targetNoteId,
    });
  }

  // Search notes by tags
  Future<List<NoteModel>> searchNotesByTag({
    String? subject,
    String? chapter,
    String? topic,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (subject != null) {
      whereClause += '${DatabaseConstants.columnSubject} = ?';
      whereArgs.add(subject);
    }
    if (chapter != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += '${DatabaseConstants.columnChapter} = ?';
      whereArgs.add(chapter);
    }
    if (topic != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += '${DatabaseConstants.columnTopic} = ?';
      whereArgs.add(topic);
    }

    final tagsData = await db.query(
      DatabaseConstants.tableTags,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    Set<int> noteIds =
        tagsData.map((e) => e[DatabaseConstants.columnNoteIdFk] as int).toSet();

    List<NoteModel> notes = [];
    for (int noteId in noteIds) {
      final noteData = await db.query(
        DatabaseConstants.tableNotes,
        where: '${DatabaseConstants.columnNoteId} = ?',
        whereArgs: [noteId],
      );
      if (noteData.isNotEmpty) {
        final tags = await _getTagsForNote(noteId);
        final connections = await _getConnectionsForNote(noteId);
        notes.add(NoteModel.fromMap(noteData.first, tags, connections));
      }
    }

    return notes;
  }

  Future<List<TagModel>> _getTagsForNote(int noteId) async {
    final db = await database;
    final tagsData = await db.query(
      DatabaseConstants.tableTags,
      where: '${DatabaseConstants.columnNoteIdFk} = ?',
      whereArgs: [noteId],
    );
    return tagsData.map((e) => TagModel.fromMap(e)).toList();
  }

  Future<List<int>> _getConnectionsForNote(int noteId) async {
    final db = await database;
    final connectionsData = await db.query(
      DatabaseConstants.tableConnectedNotes,
      where: '${DatabaseConstants.columnSourceNoteId} = ?',
      whereArgs: [noteId],
    );
    return connectionsData
        .map((e) => e[DatabaseConstants.columnTargetNoteId] as int)
        .toList();
  }
}
