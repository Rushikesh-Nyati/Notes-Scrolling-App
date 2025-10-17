import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository.dart';
import 'note_detail_screen.dart';

class SubjectNotesScreen extends StatefulWidget {
  final String subject;
  final List<NoteModel> notes;

  const SubjectNotesScreen({
    super.key,
    required this.subject,
    required this.notes,
  });

  @override
  State<SubjectNotesScreen> createState() => _SubjectNotesScreenState();
}

class _SubjectNotesScreenState extends State<SubjectNotesScreen> {
  late List<NoteModel> displayNotes;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final allNotes = await NoteRepository().getAllNotes();
    final filteredNotes = allNotes.where((note) {
      return note.tags.isNotEmpty && note.tags.first.subject == widget.subject;
    }).toList();

    setState(() {
      displayNotes = filteredNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(widget.subject),
          backgroundColor: Colors.blue,
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(Icons.image, color: Colors.blue, size: 24),
                  SizedBox(width: 12),
                  Text(
                    '${displayNotes.length} Notes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: displayNotes.isEmpty
                  ? Center(
                      child: Text(
                        'No notes in this subject',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: displayNotes.length,
                      itemBuilder: (context, index) {
                        return _buildNoteCard(displayNotes[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    final hasNotes = note.noteText.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteDetailScreen(noteId: note.id!),
          ),
        );

        if (result == true) {
          hasChanges = true;
          await _loadNotes();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      image: DecorationImage(
                        image: FileImage(File(note.imagePath)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (hasNotes)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.chat_bubble,
                            size: 16, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.tags.isNotEmpty && note.tags.first.chapter != null)
                    Text(
                      note.tags.first.chapter!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (note.tags.isNotEmpty && note.tags.first.topic != null)
                    Text(
                      note.tags.first.topic!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (note.tags.isEmpty ||
                      (note.tags.first.chapter == null &&
                          note.tags.first.topic == null))
                    Text(
                      'No details',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
