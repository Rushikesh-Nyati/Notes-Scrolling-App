import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/tag_model.dart';
// import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository.dart';

class CommonTagDialog extends StatefulWidget {
  final List<int> noteIds;

  const CommonTagDialog({super.key, required this.noteIds});

  @override
  State<CommonTagDialog> createState() => _CommonTagDialogState();
}

class _CommonTagDialogState extends State<CommonTagDialog> {
  // State variables for form fields
  String? selectedSubject;
  String? selectedChapter;
  String? selectedTopic;
  final TextEditingController _topicController = TextEditingController();

  bool _isApplying = false; // Loading state

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // ============================================
      // DIALOG CONFIGURATION
      // ============================================
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      // ============================================
      // SECTION 1: TITLE BAR
      // ============================================
      title: Row(
        children: [
          Icon(Icons.label, color: Colors.blue, size: 24),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Apply Common Tag',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '${widget.noteIds.length} images',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),

      // ============================================
      // SECTION 2: CONTENT (Form Fields)
      // ============================================
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info text
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This tag will be applied to all ${widget.noteIds.length} selected images',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ----------------------------------------
            // FIELD 1: Subject Dropdown (Required)
            // ----------------------------------------
            Text(
              'Subject *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSubject,
              decoration: InputDecoration(
                hintText: 'Select a subject',
                prefixIcon: Icon(Icons.book, color: Colors.blue, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: AppConstants.subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject, style: TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubject = value;
                  selectedChapter = null; // Reset chapter when subject changes
                });
              },
              isExpanded: true,
            ),

            SizedBox(height: 16),

            // ----------------------------------------
            // FIELD 2: Chapter Dropdown (Optional, Conditional)
            // ----------------------------------------
            if (selectedSubject != null &&
                AppConstants.subjectChapters.containsKey(selectedSubject)) ...[
              Text(
                'Chapter (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedChapter,
                decoration: InputDecoration(
                  hintText: 'Select a chapter',
                  prefixIcon:
                      Icon(Icons.menu_book, color: Colors.amber, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: AppConstants.subjectChapters[selectedSubject]!
                    .map((chapter) {
                  return DropdownMenuItem(
                    value: chapter,
                    child: Text(chapter, style: TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedChapter = value;
                  });
                },
                isExpanded: true,
              ),
              SizedBox(height: 16),
            ],

            // ----------------------------------------
            // FIELD 3: Topic Text Field (Optional)
            // ----------------------------------------
            Text(
              'Topic (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: 'e.g., Quadratic Equations',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: Icon(Icons.topic, color: Colors.green, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                selectedTopic = value.isEmpty ? null : value;
              },
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),

      // ============================================
      // SECTION 3: ACTION BUTTONS
      // ============================================
      actions: [
        // Cancel button
        TextButton(
          onPressed: _isApplying ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
            ),
          ),
        ),

        // Apply button
        ElevatedButton(
          onPressed: (selectedSubject != null && !_isApplying)
              ? _applyCommonTag
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            disabledBackgroundColor: Colors.grey[300],
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: _isApplying
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ],

      actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // ========================================
  // APPLY TAG FUNCTION
  // ========================================
  Future<void> _applyCommonTag() async {
    if (selectedSubject == null) {
      _showError('Please select a subject');
      return;
    }

    setState(() {
      _isApplying = true;
    });

    try {
      // Create the tag
      final tag = TagModel(
        subject: selectedSubject!,
        chapter: selectedChapter,
        topic: selectedTopic,
      );

      // Counter for successful operations
      int successCount = 0;
      int failCount = 0;

      // Apply tag to all selected notes
      for (int noteId in widget.noteIds) {
        try {
          final note = await NoteRepository().getNoteById(noteId);
          if (note != null) {
            // Check if tag already exists (avoid duplicates)
            bool tagExists = note.tags.any((existingTag) =>
                existingTag.subject == tag.subject &&
                existingTag.chapter == tag.chapter &&
                existingTag.topic == tag.topic);

            if (!tagExists) {
              note.tags.add(tag);
              note.updatedAt = DateTime.now();
              await NoteRepository().updateNote(note);
              successCount++;
            } else {
              successCount++; // Already has tag, count as success
            }
          } else {
            failCount++;
          }
        } catch (e) {
          // print('Error updating note $noteId: $e');
          debugPrint('Error updating note $noteId: $e');

          failCount++;
        }
      }

      setState(() {
        _isApplying = false;
      });

      // Close dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        String message;
        if (failCount == 0) {
          message = 'Tag applied to all $successCount images successfully!';
        } else {
          message = 'Tag applied to $successCount images. $failCount failed.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  failCount == 0 ? Icons.check_circle : Icons.warning,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: failCount == 0 ? Colors.green : Colors.orange,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isApplying = false;
      });
      _showError('Error applying tag: $e');
    }
  }

  // ========================================
  // ERROR HANDLING
  // ========================================
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }
}
