class AppConstants {
  static const String appName = 'Random Notes Scroller';

  static const List<String> subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'History',
    'Geography',
    'English',
    'Other'
  ];

  static const Map<String, List<String>> subjectChapters = {
    'Mathematics': ['Algebra', 'Geometry', 'Calculus', 'Statistics'],
    'Physics': ['Mechanics', 'Thermodynamics', 'Optics', 'Electromagnetism'],
    'Chemistry': ['Organic', 'Inorganic', 'Physical Chemistry'],
    'Biology': ['Cell Biology', 'Genetics', 'Ecology', 'Human Anatomy'],
    'Computer Science': [
      'Data Structures',
      'Algorithms',
      'Databases',
      'Networking'
    ],
  };

  static const int maxImageSizeInMB = 5;
}
