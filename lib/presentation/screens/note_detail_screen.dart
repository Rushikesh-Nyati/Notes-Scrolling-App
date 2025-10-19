import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/note_model.dart';
import '../../data/models/tag_model.dart';
import '../../data/repositories/note_repository.dart';
import '../../core/constants/app_constants.dart';

class NoteDetailScreen extends StatefulWidget {
  final int noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  NoteModel? note;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final loadedNote = await NoteRepository().getNoteById(widget.noteId);
    if (mounted) {
      setState(() {
        note = loadedNote;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (note == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Note not found',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Note Detail'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditTagsDialog(),
            tooltip: 'Edit Tags',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(note!.imagePath),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            note!.tags.isEmpty
                ? Text(
                    'No tags added',
                    style: TextStyle(
                        color: Colors.grey[600], fontStyle: FontStyle.italic),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: note!.tags.map((tag) {
                      return Chip(
                        avatar: const Icon(Icons.book,
                            size: 16, color: Colors.blue),
                        label: Text(tag.displayText),
                        backgroundColor: Colors.blue[50],
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 24),
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                note!.noteText.isEmpty ? 'No notes added yet' : note!.noteText,
                style: TextStyle(
                  fontSize: 15,
                  color: note!.noteText.isEmpty ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Created: ${_formatDate(note!.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.edit, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${_formatDate(note!.updatedAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTagsDialog() {
    showDialog(
      context: context,
      builder: (context) => _EditTagsDialog(
        note: note!,
        onSave: () async {
          await _loadNote();
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text(
            'Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              await NoteRepository().deleteNote(note!.id!);

              if (!mounted) return;

              navigator.pop();
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Note deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EditTagsDialog extends StatefulWidget {
  final NoteModel note;
  final VoidCallback onSave;

  const _EditTagsDialog({required this.note, required this.onSave});

  @override
  State<_EditTagsDialog> createState() => _EditTagsDialogState();
}

class _EditTagsDialogState extends State<_EditTagsDialog> {
  String? selectedSubject;
  String? selectedChapter;
  String? selectedTopic;
  final TextEditingController _topicController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note.tags.isNotEmpty) {
      final tag = widget.note.tags.first;
      selectedSubject = tag.subject;
      selectedChapter = tag.chapter;
      selectedTopic = tag.topic;
      _topicController.text = tag.topic ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: Colors.blue),
          SizedBox(width: 8),
          Text('Edit Tags'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSubject,
              decoration: InputDecoration(
                labelText: 'Subject *',
                prefixIcon: Icon(Icons.book, color: Colors.blue),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
            if (selectedSubject != null &&
                AppConstants.subjectChapters.containsKey(selectedSubject))
              DropdownButtonFormField<String>(
                value: selectedChapter,
                decoration: InputDecoration(
                  labelText: 'Chapter (Optional)',
                  prefixIcon: Icon(Icons.menu_book, color: Colors.amber),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: AppConstants.subjectChapters[selectedSubject]!
                    .map((chapter) {
                  return DropdownMenuItem(value: chapter, child: Text(chapter));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedChapter = value;
                  });
                },
              ),
            SizedBox(height: 16),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: 'Topic (Optional)',
                hintText: 'e.g., Quadratic Equations',
                prefixIcon: Icon(Icons.topic, color: Colors.green),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                selectedTopic = value.isEmpty ? null : value;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (selectedSubject != null && !_isSaving) ? _saveTag : null,
          child: _isSaving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveTag() async {
    if (selectedSubject == null) return;

    setState(() => _isSaving = true);

    try {
      final newTag = TagModel(
        subject: selectedSubject!,
        chapter: selectedChapter,
        topic: selectedTopic,
      );

      widget.note.tags.clear();
      widget.note.tags.add(newTag);
      widget.note.updatedAt = DateTime.now();

      await NoteRepository().updateNote(widget.note);

      if (!mounted) return;

      Navigator.pop(context , true );
      widget.onSave();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tags updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }
}
