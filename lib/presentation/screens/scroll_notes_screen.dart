import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository.dart';
import '../widgets/notes_modal.dart';

class TwoWayScrollScreen extends StatefulWidget {
  const TwoWayScrollScreen({super.key});

  @override
  // _TwoWayScrollScreenState createState() => _TwoWayScrollScreenState();
  State<TwoWayScrollScreen> createState() => TwoWayScrollScreenState();
}

class TwoWayScrollScreenState extends State<TwoWayScrollScreen> {
  late PageController _pageController;
  int currentIndex = 0;
  List<NoteModel> notes = [];
  final TextEditingController _notesController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final loadedNotes = await NoteRepository().getAllNotes();
    setState(() {
      notes = loadedNotes;
      isLoading = false;
      if (notes.isNotEmpty) {
        _notesController.text = notes[0].noteText;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...'), backgroundColor: Colors.blue),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (notes.isEmpty) {
      return Scaffold(
        appBar:
            AppBar(title: Text('Random Scroll'), backgroundColor: Colors.blue),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No notes available',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/upload'),
                child: Text('Add First Note'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Random Scroll Mode'),
        backgroundColor: Colors.blue,
        actions: [
          // Refresh button - resets to first image
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetScroll,
            tooltip: 'Reset to Start',
          ),

          // Progress button - shows how many viewed
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: _showProgress,
            tooltip: 'View Progress',
          ),

          // Three-dot menu with options
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Tags'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'notes',
                child: Row(
                  children: [
                    Icon(Icons.note_add, size: 20),
                    SizedBox(width: 8),
                    Text('Add Notes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'connect',
                child: Row(
                  children: [
                    Icon(Icons.link, size: 20),
                    SizedBox(width: 8),
                    Text('Connect Notes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // TOP: "Previous" button/indicator
          GestureDetector(
            onTap: _previousImage,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              color: Colors.grey[100],
              child: Column(
                children: [
                  Icon(Icons.keyboard_arrow_up,
                      color: Colors.grey[700], size: 28),
                  Text(
                    'Previous',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // MIDDLE: Scrollable image viewer with PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection:
                  Axis.vertical, // THIS IS KEY - vertical scrolling
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                  _notesController.text = notes[index].noteText;
                });
              },
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];

                return Column(
                  children: [
                    // IMAGE SECTION (takes 60% of available space)
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onDoubleTap: () => _openFullscreen(note),
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: Container(
                            color: Colors.black,
                            child: Center(
                              child: Image.file(
                                File(note.imagePath),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // TAGS AND NOTES SECTION (takes 40% of space)
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display tags as chips
                              Text(
                                'Tags:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: note.tags.map((tag) {
                                  return Chip(
                                    avatar: Icon(Icons.book,
                                        size: 16, color: Colors.blue),
                                    label: Text(
                                      tag.displayText,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.blue[50],
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                  );
                                }).toList(),
                              ),

                              SizedBox(height: 16),

                              // Inline notes text field
                              TextField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: 'Notes',
                                  hintText: 'Add your notes here...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon:
                                      Icon(Icons.note, color: Colors.blue),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                maxLines: 3,
                                onChanged: (text) =>
                                    _updateNotes(note.id!, text),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // BOTTOM: "Next" button/indicator
          GestureDetector(
            onTap: _nextImage,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              color: Colors.grey[100],
              child: Column(
                children: [
                  Text(
                    'Next',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Icon(Icons.keyboard_arrow_down,
                      color: Colors.grey[700], size: 28),
                ],
              ),
            ),
          ),

          // PROGRESS BAR at bottom
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Image ${currentIndex + 1} of ${notes.length}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 16),
                // Progress percentage
                Text(
                  '(${((currentIndex + 1) / notes.length * 100).toStringAsFixed(0)}%)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to previous image
  void _previousImage() {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Already at first image')),
      );
    }
  }

  // Navigate to next image
  void _nextImage() {
    if (currentIndex < notes.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Already at last image')),
      );
    }
  }

  // Update notes in database when user types
  void _updateNotes(int noteId, String text) async {
    final note = notes.firstWhere((n) => n.id == noteId);
    note.noteText = text;
    await NoteRepository().updateNote(note);
  }

  // Handle three-dot menu actions
  void _handleMenuAction(String action) {
    final currentNote = notes[currentIndex];

    switch (action) {
      case 'notes':
        _showNotesModal();
        break;
      case 'edit':
        _showEditTagsDialog();
        break;
      case 'connect':
        _showConnectNotesScreen();
        break;
      case 'share':
        _shareImage(currentNote);
        break;
      case 'delete':
        _confirmDelete(currentNote);
        break;
    }
  }

  // Show full notes editor
  void _showNotesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => NotesModal(note: notes[currentIndex]),
    );
  }

  // Show edit tags dialog (placeholder)
  void _showEditTagsDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit tags feature coming soon!')),
    );
  }

  // Show connect notes screen (placeholder)
  void _showConnectNotesScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connect notes feature coming soon!')),
    );
  }

  // Share image (placeholder)
  void _shareImage(NoteModel note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  // Confirm delete with dialog
  void _confirmDelete(NoteModel note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note?'),
        content: Text(
            'Are you sure you want to delete this note? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Capture context-dependent objects BEFORE async operation
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              // Async operation
              await NoteRepository().deleteNote(note.id!);

              // Check mounted after async
              if (!mounted) return;

              // Use captured objects
              navigator.pop();
              navigator.pop(); // Go back to home
              messenger.showSnackBar(
                const SnackBar(content: Text('Note deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Reset to first image
  void _resetScroll() {
    _pageController.animateToPage(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Show progress dialog
  void _showProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Viewing Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / notes.length,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'You have viewed ${currentIndex + 1} of ${notes.length} images',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '${((currentIndex + 1) / notes.length * 100).toStringAsFixed(1)}% Complete',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Open fullscreen image viewer
  void _openFullscreen(NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: Image.file(File(note.imagePath)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
