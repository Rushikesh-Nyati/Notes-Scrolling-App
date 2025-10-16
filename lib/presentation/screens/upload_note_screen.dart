import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/note_model.dart';
import '../../data/models/tag_model.dart';
import '../../data/repositories/note_repository.dart';
import '../widgets/image_picker_bottom_sheet.dart';
import '../widgets/tag_input_widget.dart';

class UploadNoteScreen extends StatefulWidget {
  const UploadNoteScreen({super.key});

  @override
  State<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends State<UploadNoteScreen> {
  final NoteRepository _repository = NoteRepository();
  final TextEditingController _noteController = TextEditingController();

  File? _selectedImage;
  List<TagModel> _tags = [];
  bool _isSaving = false;

  void _selectImage() {
    ImagePickerBottomSheet.show(context, (file) {
      setState(() {
        _selectedImage = file;
      });
    });
  }

  Future<void> _saveNote() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    if (_tags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one tag')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final note = NoteModel(
        imagePath: _selectedImage!.path,
        noteText: _noteController.text,
        tags: _tags,
      );

      await _repository.createNote(note);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Note'),
        actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveNote,
            ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview
            GestureDetector(
              onTap: _selectImage,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to select image',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Note text field
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Add Note (Optional)',
                hintText: 'Write something about this note...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Tag input widget
            TagInputWidget(
              initialTags: _tags,
              onTagsChanged: (tags) {
                setState(() {
                  _tags = tags;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
