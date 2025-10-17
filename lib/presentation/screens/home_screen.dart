import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository.dart';
import '../../core/routes/app_routes.dart';
import 'subject_notes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<NoteModel> allNotes = [];
  Map<String, List<NoteModel>> notesBySubject = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => isLoading = true);

    final notes = await NoteRepository().getAllNotes();

    Map<String, List<NoteModel>> grouped = {};
    for (var note in notes) {
      if (note.tags.isNotEmpty) {
        final subject = note.tags.first.subject;
        if (!grouped.containsKey(subject)) {
          grouped[subject] = [];
        }
        grouped[subject]!.add(note);
      }
    }

    setState(() {
      allNotes = notes;
      notesBySubject = grouped;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('My Notes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle),
            onPressed: () async {
              await Navigator.pushNamed(context, '/scroll');
              _loadNotes();
            },
            tooltip: 'Random Scroll',
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notesBySubject.isEmpty
              ? _buildEmptyState()
              : _buildSubjectGrid(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/upload');
          _loadNotes();
        },
        icon: Icon(Icons.add_a_photo),
        label: Text('Add Note'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add, size: 80, color: Colors.grey[400]),
          SizedBox(height: 24),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Start by adding your first note',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(context, '/upload');
              _loadNotes();
            },
            icon: Icon(Icons.add_a_photo),
            label: Text('Add First Note'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectGrid() {
    final subjects = notesBySubject.keys.toList()..sort();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subjects',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${subjects.length} subjects • ${allNotes.length} notes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final subject = subjects[index];
                final notes = notesBySubject[subject]!;
                return _buildSubjectCard(subject, notes);
              },
              childCount: subjects.length,
            ),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildSubjectCard(String subject, List<NoteModel> notes) {
    final icon = _getSubjectIcon(subject);
    final color = _getSubjectColor(subject);
    final firstNote = notes.first;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectNotesScreen(
              subject: subject,
              notes: notes,
            ),
          ),
        );

        // Reload if anything changed
        if (result == true) {
          _loadNotes();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  image: DecorationImage(
                    image: FileImage(File(firstNote.imagePath)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(icon, style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subject,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.image, size: 12, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        '${notes.length} notes',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Mathematics':
        return '📐';
      case 'Physics':
        return '⚛️';
      case 'Chemistry':
        return '🧪';
      case 'Biology':
        return '🧬';
      case 'Computer Science':
        return '💻';
      case 'English':
        return '📖';
      case 'History':
        return '📜';
      case 'Geography':
        return '🌍';
      default:
        return '📚';
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Mathematics':
        return Colors.blue;
      case 'Physics':
        return Colors.purple;
      case 'Chemistry':
        return Colors.green;
      case 'Biology':
        return Colors.teal;
      case 'Computer Science':
        return Colors.orange;
      case 'English':
        return Colors.red;
      case 'History':
        return Colors.brown;
      case 'Geography':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }
}
