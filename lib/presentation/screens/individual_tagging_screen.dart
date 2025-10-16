import 'dart:io'; // ← Add this line
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import '../../data/models/note_model.dart';
import '../../data/models/tag_model.dart';
import '../../data/repositories/note_repository.dart';
import '../../core/constants/app_constants.dart';

class IndividualTaggingScreen extends StatefulWidget {
  final List<int> noteIds;

  const IndividualTaggingScreen({super.key, required this.noteIds});

  @override
  State<IndividualTaggingScreen> createState() =>
      IndividualTaggingScreenState();
}

// @override
State<IndividualTaggingScreen> createState() => IndividualTaggingScreenState();

class IndividualTaggingScreenState extends State<IndividualTaggingScreen> {
  late PageController _pageController;
  int currentIndex = 0;
  String? selectedSubject;
  String? selectedChapter;
  String? selectedTopic;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tag Individual Images (${widget.noteIds.length})'),
            Text(
              'Image ${currentIndex + 1}/${widget.noteIds.length}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.noteIds.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
            // Reset selections for new image
            selectedSubject = null;
            selectedChapter = null;
            selectedTopic = null;
          });
        },
        itemBuilder: (context, index) {
          return _buildTaggingPage(widget.noteIds[index]);
        },
      ),
    );
  }

  Widget _buildTaggingPage(int noteId) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image preview
          FutureBuilder<NoteModel?>(
            future: NoteRepository().getNoteById(noteId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              return Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(snapshot.data!.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 24),

          // Subject dropdown
          DropdownButtonFormField<String>(
            value: selectedSubject,
            decoration: InputDecoration(
              labelText: 'Subject',
              prefixIcon: Icon(Icons.book),
              border: OutlineInputBorder(),
            ),
            items: AppConstants.subjects.map((subject) {
              return DropdownMenuItem(value: subject, child: Text(subject));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedSubject = value;
                selectedChapter = null;
              });
            },
          ),

          SizedBox(height: 16),

          // Chapter dropdown (conditional)
          if (selectedSubject != null &&
              AppConstants.subjectChapters.containsKey(selectedSubject))
            DropdownButtonFormField<String>(
              value: selectedChapter,
              decoration: InputDecoration(
                labelText: 'Chapter (Optional)',
                prefixIcon: Icon(Icons.menu_book),
                border: OutlineInputBorder(),
              ),
              items:
                  AppConstants.subjectChapters[selectedSubject]!.map((chapter) {
                return DropdownMenuItem(value: chapter, child: Text(chapter));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedChapter = value;
                });
              },
            ),

          SizedBox(height: 16),

          // Topic text field
          TextField(
            decoration: InputDecoration(
              labelText: 'Topic (Optional)',
              hintText: 'e.g., Quadratic Equations',
              prefixIcon: Icon(Icons.topic),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              selectedTopic = value.isEmpty ? null : value;
            },
          ),

          SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _skipCurrent(),
                  child: Text('Skip'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedSubject != null
                      ? () => _saveAndNext(noteId)
                      : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(currentIndex < widget.noteIds.length - 1
                      ? 'Save & Next'
                      : 'Save & Finish'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _skipCurrent() {
    if (currentIndex < widget.noteIds.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _saveAndNext(int noteId) async {
    if (selectedSubject == null) return;

    // Create tag
    final tag = TagModel(
      subject: selectedSubject!,
      chapter: selectedChapter,
      topic: selectedTopic,
    );

    // Update note with tag
    final note = await NoteRepository().getNoteById(noteId);
    if (note != null) {
      note.tags.add(tag);
      await NoteRepository().updateNote(note);
    }

    if (currentIndex < widget.noteIds.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All images tagged successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
