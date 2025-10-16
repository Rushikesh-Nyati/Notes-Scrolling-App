import 'package:flutter/material.dart';
// import 'dart:io';
import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository.dart';

class NotesModal extends StatefulWidget {
  final NoteModel note;

  const NotesModal({super.key, required this.note});

  @override
  State<NotesModal> createState() => _NotesModalState();
}

class _NotesModalState extends State<NotesModal> {
  late TextEditingController _controller;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    // Initialize the text controller with existing notes
    _controller = TextEditingController(text: widget.note.noteText);

    // Listen for changes to enable save button
    _controller.addListener(() {
      if (!_isModified) {
        setState(() {
          _isModified = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Makes modal take 75% of screen height
      height: MediaQuery.of(context).size.height * 0.75,

      // Adjust for keyboard when it appears
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      child: Column(
        children: [
          // ============================================
          // SECTION 1: HEADER with title and close button
          // ============================================
          _buildHeader(),

          // ============================================
          // SECTION 2: MAIN TEXT EDITOR (expandable)
          // ============================================
          _buildTextEditor(),

          // ============================================
          // SECTION 3: LAST EDITED TIMESTAMP
          // ============================================
          _buildTimestamp(),

          // ============================================
          // SECTION 4: FORMATTING TOOLBAR
          // ============================================
          _buildFormattingToolbar(),

          // ============================================
          // SECTION 5: ACTION BUTTONS (Cancel/Save)
          // ============================================
          _buildActionButtons(),
        ],
      ),
    );
  }

  // ========================================
  // SECTION 1: Header
  // ========================================
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Icon(Icons.note_alt, color: Colors.blue, size: 24),
          SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              'Notes & Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Close button
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600]),
            onPressed: () {
              if (_isModified) {
                _showUnsavedChangesDialog();
              } else {
                Navigator.pop(context);
              }
            },
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  // ========================================
  // SECTION 2: Text Editor
  // ========================================
  Widget _buildTextEditor() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        child: TextField(
          controller: _controller,

          // Styling
          decoration: InputDecoration(
            hintText:
                'Write your notes here...\n\n• Key concepts\n• Important formulas\n• Things to remember',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),

            // Border styling
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),

            // Background color
            filled: true,
            fillColor: Colors.grey[50],

            // Content padding
            contentPadding: EdgeInsets.all(16),
          ),

          // Text style
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.grey[800],
            fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
          ),

          // Behavior
          maxLines: null, // Unlimited lines
          expands: true, // Fill available space
          textAlignVertical: TextAlignVertical.top,

          // Keyboard type
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
    );
  }

  // ========================================
  // SECTION 3: Timestamp
  // ========================================
  Widget _buildTimestamp() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
          SizedBox(width: 6),
          Text(
            'Last edited: ${_formatDate(widget.note.updatedAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // SECTION 4: Formatting Toolbar
  // ========================================
  Widget _buildFormattingToolbar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bold button
          _buildToolbarButton(
            icon: Icons.format_bold,
            label: 'Bold',
            isActive: _isBold,
            onPressed: () {
              setState(() {
                _isBold = !_isBold;
              });
            },
          ),

          // Italic button
          _buildToolbarButton(
            icon: Icons.format_italic,
            label: 'Italic',
            isActive: _isItalic,
            onPressed: () {
              setState(() {
                _isItalic = !_isItalic;
              });
            },
          ),

          // Attachment button (placeholder)
          _buildToolbarButton(
            icon: Icons.attach_file,
            label: 'Attach',
            isActive: false,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Attachments coming soon!')),
              );
            },
          ),

          // Bullet list button (placeholder)
          _buildToolbarButton(
            icon: Icons.format_list_bulleted,
            label: 'List',
            isActive: false,
            onPressed: () {
              _controller.text += '\n• ';
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            },
          ),

          // Checkbox button (placeholder)
          _buildToolbarButton(
            icon: Icons.check_box,
            label: 'Tasks',
            isActive: false,
            onPressed: () {
              _controller.text += '\n☐ ';
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper: Individual toolbar button
  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[100] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive ? Colors.blue[700] : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // ========================================
  // SECTION 5: Action Buttons
  // ========================================
  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                if (_isModified) {
                  _showUnsavedChangesDialog();
                } else {
                  Navigator.pop(context);
                }
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          SizedBox(width: 16),

          // Save button
          Expanded(
            child: ElevatedButton(
              onPressed: _isModified ? _saveNotes : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // HELPER FUNCTIONS
  // ========================================

  // Save notes to database
  Future<void> _saveNotes() async {
    try {
      // Update note object
      widget.note.noteText = _controller.text;
      widget.note.updatedAt = DateTime.now();

      // Save to database
      await NoteRepository().updateNote(widget.note);

      // Show success message
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Notes saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Error saving notes: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Show unsaved changes warning dialog
  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Unsaved Changes'),
          ],
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close modal
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Discard'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Format date to readable string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final noteDate = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (noteDate == today) {
      dateStr = 'Today';
    } else if (noteDate == yesterday) {
      dateStr = 'Yesterday';
    } else {
      dateStr = '${date.day}/${date.month}/${date.year}';
    }

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$dateStr at $hour:$minute';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
