import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../api_service.dart';

class StoryViewPage extends StatefulWidget {
  final String token;
  final List<Map<String, dynamic>> stories;
  final int initialIndex;

  const StoryViewPage({
    super.key,
    required this.token,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> {
  late PageController _pageController;
  int _currentStoryIndex = 0;
  Timer? _timer;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPaused = false;

  final Map<int, bool> _viewedStories = {}; // Track viewed stories

  @override
  void initState() {
    super.initState();
    _currentStoryIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentStoryIndex);
    _startStoryTimer();
    _markStoryAsViewed(_currentStoryIndex);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startStoryTimer() {
    _timer?.cancel();
    
    final currentStory = widget.stories[_currentStoryIndex];
    final mediaType = currentStory['mediaType'] ?? 'text';
    int duration = currentStory['duration'] ?? 5;

    if (mediaType == 'video') {
      _initializeVideo(currentStory['mediaUrl']);
      return; // Video will handle its own timing
    }

    _timer = Timer(Duration(seconds: duration), () {
      if (mounted && !_isPaused) {
        _nextStory();
      }
    });
  }

  Future<void> _initializeVideo(String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty) {
      _nextStory();
      return;
    }

    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      
      await _videoController!.initialize();
      
      if (mounted) {
        setState(() => _isVideoInitialized = true);
        _videoController!.play();
        
        _videoController!.addListener(() {
          if (_videoController!.value.position >= _videoController!.value.duration) {
            _nextStory();
          }
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        _nextStory();
      }
    }
  }

  void _nextStory() {
    if (_currentStoryIndex < widget.stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _isVideoInitialized = false;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _markStoryAsViewed(_currentStoryIndex);
      _startStoryTimer();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        _isVideoInitialized = false;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStoryTimer();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _timer?.cancel();
        _videoController?.pause();
      } else {
        _startStoryTimer();
        _videoController?.play();
      }
    });
  }

  Future<void> _markStoryAsViewed(int index) async {
    final storyId = widget.stories[index]['_id'];
    
    // Ne pas marquer deux fois
    if (_viewedStories[index] == true) return;
    
    _viewedStories[index] = true;

    try {
      await ApiService.viewStory(widget.token, storyId);
    } catch (e) {
      debugPrint('Error marking story as viewed: $e');
    }
  }

  Future<void> _deleteStory(int index) async {
    final storyId = widget.stories[index]['_id'];
    
    try {
      await ApiService.deleteStory(widget.token, storyId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story supprimée'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Retirer la story de la liste
        widget.stories.removeAt(index);
        
        if (widget.stories.isEmpty) {
          Navigator.pop(context, true);
        } else {
          if (_currentStoryIndex >= widget.stories.length) {
            _currentStoryIndex = widget.stories.length - 1;
          }
          setState(() {});
          _startStoryTimer();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la story'),
        content: const Text('Voulez-vous vraiment supprimer cette story ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStory(index);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String? _getUserIdFromToken() {
    try {
      // Décoder le JWT pour extraire l'ID utilisateur
      final parts = widget.token.split('.');
      if (parts.length != 3) return null;
      
      // Décoder la partie payload (partie 2)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payloadMap = json.decode(decoded);
      
      return payloadMap['userId'] ?? payloadMap['id'] ?? payloadMap['sub'];
    } catch (e) {
      debugPrint('Erreur lors du décodage du token: $e');
      return null;
    }
  }

  bool _isOwner(Map<String, dynamic> story) {
    // Vérifier si l'utilisateur connecté est le propriétaire de la story
    final currentUserId = _getUserIdFromToken();
    if (currentUserId == null) return false;
    
    final storyUserId = story['userId'];
    
    // Si userId est un objet (populate), extraire l'_id
    if (storyUserId is Map) {
      final storyUserIdString = storyUserId['_id'] ?? storyUserId['id'];
      return storyUserIdString == currentUserId;
    }
    
    // Si c'est juste l'ID en string
    return storyUserId == currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          final tapPosition = details.globalPosition.dx;
          
          if (tapPosition < screenWidth / 3) {
            _previousStory();
          } else if (tapPosition > screenWidth * 2 / 3) {
            _nextStory();
          } else {
            _togglePause();
          }
        },
        child: Stack(
          children: [
            // PageView pour swipe
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStoryIndex = index;
                  _isVideoInitialized = false;
                });
                _markStoryAsViewed(index);
                _startStoryTimer();
              },
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                return _buildStoryContent(widget.stories[index]);
              },
            ),

            // Barre de progression en haut
            SafeArea(
              child: Column(
                children: [
                  _buildProgressBar(),
                  _buildHeader(),
                ],
              ),
            ),

            // Indicateur de pause
            if (_isPaused)
              const Center(
                child: Icon(
                  Icons.pause_circle_filled,
                  size: 80,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: List.generate(
          widget.stories.length,
          (index) => Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index < _currentStoryIndex
                    ? Colors.white
                    : index == _currentStoryIndex
                        ? Colors.white70
                        : Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final story = widget.stories[_currentStoryIndex];
    final user = story['userId'] as Map<String, dynamic>?;
    final userName = user?['name'] ?? 'Utilisateur';
    final userImage = user?['profileImage'] ?? '';
    final createdAt = story['createdAt'];
    final timeAgo = _formatTimeAgo(createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            backgroundImage: userImage.isNotEmpty
                ? NetworkImage(userImage)
                : null,
            child: userImage.isEmpty
                ? Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          if (_isOwner(story))
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmation(_currentStoryIndex);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStoryContent(Map<String, dynamic> story) {
    final mediaType = story['mediaType'] ?? 'text';
    final mediaUrl = story['mediaUrl'] ?? '';
    final content = story['content'] ?? '';
    final backgroundColor = story['backgroundColor'] ?? '#00D4FF';

    if (mediaType == 'image' && mediaUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            mediaUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.error, color: Colors.white, size: 80),
              );
            },
          ),
          if (content.isNotEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    } else if (mediaType == 'video' && mediaUrl.isNotEmpty) {
      if (_videoController != null && _isVideoInitialized) {
        return Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
    } else {
      // Story texte
      Color bgColor;
      try {
        bgColor = Color(int.parse(backgroundColor.replaceFirst('#', '0xFF')));
      } catch (e) {
        bgColor = const Color(0xFF00D4FF);
      }

      return Container(
        color: bgColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return 'Maintenant';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'À l\'instant';
      } else if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours}h';
      } else {
        return 'Il y a ${difference.inDays}j';
      }
    } catch (e) {
      return 'Maintenant';
    }
  }
}
