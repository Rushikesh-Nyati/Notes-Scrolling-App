class TagModel {
  final int? tagId;
  final int? noteId;
  final String subject;
  final String? chapter;
  final String? topic;

  TagModel({
    this.tagId,
    this.noteId,
    required this.subject,
    this.chapter,
    this.topic,
  });

  Map<String, dynamic> toMap() {
    return {
      'tag_id': tagId,
      'note_id': noteId,
      'subject': subject,
      'chapter': chapter,
      'topic': topic,
    };
  }

  factory TagModel.fromMap(Map<String, dynamic> map) {
    return TagModel(
      tagId: map['tag_id'],
      noteId: map['note_id'],
      subject: map['subject'],
      chapter: map['chapter'],
      topic: map['topic'],
    );
  }

  String get displayText {
    String text = subject;
    if (chapter != null && chapter!.isNotEmpty) text += ' - $chapter';
    if (topic != null && topic!.isNotEmpty) text += ' - $topic';
    return text;
  }
}
