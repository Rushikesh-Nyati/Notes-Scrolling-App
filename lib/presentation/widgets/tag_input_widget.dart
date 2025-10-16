import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/tag_model.dart';

class TagInputWidget extends StatefulWidget {
  final List<TagModel> initialTags;
  final Function(List<TagModel>) onTagsChanged;

  const TagInputWidget({
    super.key,
    required this.initialTags,
    required this.onTagsChanged,
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  List<TagModel> _tags = [];
  String? _selectedSubject;
  String? _selectedChapter;
  String? _selectedTopic;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  void _addTag() {
    if (_selectedSubject != null) {
      final newTag = TagModel(
        subject: _selectedSubject!,
        chapter: _selectedChapter,
        topic: _selectedTopic,
      );
      setState(() {
        _tags.add(newTag);
        _selectedSubject = null;
        _selectedChapter = null;
        _selectedTopic = null;
      });
      widget.onTagsChanged(_tags);
    }
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // Display current tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.asMap().entries.map((entry) {
            return Chip(
              label: Text(entry.value.displayText),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => _removeTag(entry.key),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Subject dropdown
        DropdownButtonFormField<String>(
          value: _selectedSubject,
          decoration: const InputDecoration(labelText: 'Subject'),
          items: AppConstants.subjects.map((subject) {
            return DropdownMenuItem(value: subject, child: Text(subject));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSubject = value;
              _selectedChapter = null;
            });
          },
        ),

        const SizedBox(height: 12),

        // Chapter dropdown (conditional)
        if (_selectedSubject != null &&
            AppConstants.subjectChapters.containsKey(_selectedSubject))
          DropdownButtonFormField<String>(
            value: _selectedChapter,
            decoration: const InputDecoration(labelText: 'Chapter (Optional)'),
            items:
                AppConstants.subjectChapters[_selectedSubject]!.map((chapter) {
              return DropdownMenuItem(value: chapter, child: Text(chapter));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedChapter = value;
              });
            },
          ),

        const SizedBox(height: 12),

        // Topic text field
        TextField(
          decoration: const InputDecoration(
            labelText: 'Topic (Optional)',
            hintText: 'e.g., Quadratic Equations',
          ),
          onChanged: (value) {
            _selectedTopic = value.isEmpty ? null : value;
          },
        ),

        const SizedBox(height: 16),

        // Add tag button
        ElevatedButton.icon(
          onPressed: _selectedSubject != null ? _addTag : null,
          icon: const Icon(Icons.add),
          label: const Text('Add Tag'),
        ),
      ],
    );
  }
}
