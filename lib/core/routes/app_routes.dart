import 'package:flutter/material.dart';
import '../../presentation/screens/home_screen.dart';
// import '../../presentation/screens/grouped_gallery_screen.dart';
import '../../presentation/screens/upload_note_screen.dart';
import '../../presentation/screens/note_detail_screen.dart';
import '../../presentation/screens/scroll_notes_screen.dart';
import '../../presentation/screens/individual_tagging_screen.dart';

class AppRoutes {
  // ============================================
  // ROUTE NAME CONSTANTS
  // ============================================
  static const String home = '/';
  static const String uploadNote = '/upload';
  static const String noteDetail = '/detail';
  static const String scrollNotes = '/scroll';
  static const String individualTagging = '/individual-tagging';

  // ============================================
  // ROUTES MAP (Simple Routes without Arguments)
  // ============================================
  static Map<String, WidgetBuilder> routes = {
    // home: (context) => const GroupedGalleryScreen(),
    home: (context) => const HomeScreen(),
    uploadNote: (context) => const UploadNoteScreen(),
    scrollNotes: (context) => TwoWayScrollScreen(),
  };

  // ============================================
  // ROUTE GENERATOR (For Routes with Arguments)
  // ============================================
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ---------------------------------------
      // Note Detail Screen (Requires note ID)
      // ---------------------------------------
      case noteDetail:
        final noteId = settings.arguments as int?;
        if (noteId == null) {
          return _errorRoute('Note ID is required');
        }
        return MaterialPageRoute(
          builder: (context) => NoteDetailScreen(noteId: noteId),
          settings: settings,
        );

      // ---------------------------------------
      // Individual Tagging Screen (Requires note IDs)
      // ---------------------------------------
      case individualTagging:
        final noteIds = settings.arguments as List<int>?;
        if (noteIds == null || noteIds.isEmpty) {
          return _errorRoute('Note IDs are required');
        }
        return MaterialPageRoute(
          builder: (context) => IndividualTaggingScreen(noteIds: noteIds),
          settings: settings,
        );

      // ---------------------------------------
      // Default: Page not found
      // ---------------------------------------
      default:
        return _errorRoute('Page not found: ${settings.name}');
    }
  }

  // ============================================
  // ERROR ROUTE (For invalid routes)
  // ============================================
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  home,
                  (route) => false,
                ),
                icon: Icon(Icons.home),
                label: Text('Go to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // NAVIGATION HELPER METHODS
  // ============================================

  // Navigate to home screen
  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }

  // Navigate to upload screen
  static void navigateToUpload(BuildContext context) {
    Navigator.pushNamed(context, uploadNote);
  }

  // Navigate to note detail screen
  static void navigateToNoteDetail(BuildContext context, int noteId) {
    Navigator.pushNamed(context, noteDetail, arguments: noteId);
  }

  // Navigate to scroll screen
  static void navigateToScrollNotes(BuildContext context) {
    Navigator.pushNamed(context, scrollNotes);
  }

  // Navigate to individual tagging screen
  static void navigateToIndividualTagging(
    BuildContext context,
    List<int> noteIds,
  ) {
    Navigator.pushNamed(context, individualTagging, arguments: noteIds);
  }
}
