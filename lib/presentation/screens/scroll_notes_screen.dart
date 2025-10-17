import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui';
import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository.dart';
import '../widgets/notes_modal.dart';

class TwoWayScrollScreen extends StatefulWidget {
  const TwoWayScrollScreen({super.key});

  @override
  State<TwoWayScrollScreen> createState() => TwoWayScrollScreenState();
}

class TwoWayScrollScreenState extends State<TwoWayScrollScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int currentIndex = 0;
  List<NoteModel> notes = [];
  bool isLoading = true;
  bool _showOverlays = true;
  late AnimationController _overlayAnimationController;
  late Animation<double> _overlayAnimation;

  @override
  void initState() {
    super.initState();
    // Start at a high page number to allow infinite scroll both ways
    _pageController = PageController(initialPage: 10000);
    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _overlayAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _overlayAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _overlayAnimationController.forward();
    _loadNotes();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  Future<void> _loadNotes() async {
    final loadedNotes = await NoteRepository().getAllNotes();
    setState(() {
      notes = loadedNotes;
      isLoading = false;
      if (notes.isNotEmpty) {
        // Set initial index to 0 (actual note position)
        currentIndex = 0;
      }
    });
  }

  void _toggleOverlays() {
    setState(() {
      _showOverlays = !_showOverlays;
      if (_showOverlays) {
        _overlayAnimationController.forward();
      } else {
        _overlayAnimationController.reverse();
      }
    });
  }

  // Get actual note index from infinite page index
  int _getActualIndex(int pageIndex) {
    if (notes.isEmpty) return 0;
    return pageIndex % notes.length;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading notes...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (notes.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 64, color: Colors.white30),
              SizedBox(height: 16),
              Text(
                'No notes available',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/upload'),
                icon: Icon(Icons.add_a_photo),
                label: Text('Add First Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main PageView - Infinite scrolling
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (pageIndex) {
              setState(() {
                currentIndex = _getActualIndex(pageIndex);
              });
              HapticFeedback.lightImpact();
            },
            itemBuilder: (context, pageIndex) {
              final actualIndex = _getActualIndex(pageIndex);
              return _buildNotePage(notes[actualIndex]);
            },
          ),

          // Top Gradient Overlay
          if (_showOverlays)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _overlayAnimation,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Progress Indicator (Top-left)
          if (_showOverlays)
            Positioned(
              top: 50,
              left: 16,
              child: FadeTransition(
                opacity: _overlayAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${currentIndex + 1}/${notes.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Three-Dot Menu (Top-right)
          if (_showOverlays)
            Positioned(
              top: 45,
              right: 16,
              child: FadeTransition(
                opacity: _overlayAnimation,
                child: _buildThreeDotMenu(),
              ),
            ),

          // Bottom Overlay Bar
          if (_showOverlays)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _overlayAnimation,
                child: _buildBottomOverlay(notes[currentIndex]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotePage(NoteModel note) {
    return GestureDetector(
      onTap: _toggleOverlays,
      onDoubleTap: () => _openFullscreen(note),
      child: Container(
        color: Colors.black,
        child: Center(
          child: Hero(
            tag: 'note_${note.id}',
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.file(
                File(note.imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image,
                              size: 64, color: Colors.white30),
                          SizedBox(height: 8),
                          Text(
                            'Image not found',
                            style: TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThreeDotMenu() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white, size: 24),
              onPressed: _showMenuOptions,
            ),
          ),
        ),
      ),
    );
  }

  void _showMenuOptions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              _menuItem(Icons.note_add, 'Add Note', () {
                Navigator.pop(context);
                _showNotesModal();
              }),
              _menuItem(Icons.edit, 'Edit Tags', () {
                Navigator.pop(context);
                _showEditTagsDialog();
              }),
              _menuItem(Icons.link, 'Connect Notes', () {
                Navigator.pop(context);
                _showConnectNotesScreen();
              }),
              _menuItem(Icons.share, 'Share', () {
                Navigator.pop(context);
                _shareImage(notes[currentIndex]);
              }),
              Divider(color: Colors.white10),
              _menuItem(Icons.delete, 'Delete', () {
                Navigator.pop(context);
                _confirmDelete(notes[currentIndex]);
              }, isDestructive: true),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomOverlay(NoteModel note) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: note.tags.map((tag) {
                        return Container(
                          margin: EdgeInsets.only(right: 8),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('📚', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 4),
                              Text(
                                tag.subject,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (tag.chapter != null) ...[
                                Text(' • ',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                Text(
                                  tag.chapter!,
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                _actionIcon(Icons.chat_bubble_outline, () => _showNotesModal()),
                SizedBox(width: 16),
                _actionIcon(Icons.favorite_border, () => _toggleFavorite()),
                SizedBox(width: 16),
                _actionIcon(Icons.bookmark_border, () => _toggleBookmark()),
              ],
            ),
            if (note.noteText.isNotEmpty) ...[
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  note.noteText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(4),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
          shadows: [
            Shadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotesModal(note: notes[currentIndex]),
    );
  }

  void _showEditTagsDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit tags feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showConnectNotesScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connect notes feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _shareImage(NoteModel note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _toggleFavorite() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked as favorite!'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _toggleBookmark() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved to bookmarks!'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _confirmDelete(NoteModel note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Note?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              await NoteRepository().deleteNote(note.id!);

              if (!mounted) return;

              navigator.pop();
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Note deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openFullscreen(NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Image.file(File(note.imagePath)),
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _overlayAnimationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}
