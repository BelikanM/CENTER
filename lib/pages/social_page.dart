import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../api_service.dart';
import '../components/post_card.dart';
import '../components/story_circle.dart';
import 'create_publication_page.dart';
import 'map_view_page.dart';
import 'comments_page.dart';
import 'all_stories_page.dart';
import 'create_story_page.dart';
import 'story_view_page.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _showFab = true;

  // État de chargement et données depuis l'API
  bool _isLoading = false;
  List<dynamic> _publications = [];
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _fabAnimationController.forward();
    
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && _showFab) {
        setState(() => _showFab = false);
        _fabAnimationController.reverse();
      } else if (_scrollController.offset <= 100 && !_showFab) {
        setState(() => _showFab = true);
        _fabAnimationController.forward();
      }

      // Infinite scroll
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMorePublications();
      }
    });

    _loadPublications();
    _listenToWebSocket();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Recharger quand l'app revient au premier plan
    if (state == AppLifecycleState.resumed) {
      _loadPublications();
    }
  }

  void _listenToWebSocket() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.webSocketStream.listen((message) {
      // Recharger les publications quand un nouveau commentaire est ajouté
      if (message['type'] == 'new_comment') {
        _loadPublications();
      }
      // Recharger aussi pour les nouvelles publications
      if (message['type'] == 'new_publication') {
        _loadPublications();
      }
    });
  }

  Future<void> _loadPublications() async {
    if (_isLoading) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken;

    if (token == null) {
      setState(() {
        _error = 'Non authentifié';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.getPublications(token, page: 1, limit: 20);
      if (mounted) {
        setState(() {
          _publications = result['publications'] ?? [];
          _currentPage = 1;
          _hasMore = (result['pagination']?['currentPage'] ?? 1) < (result['pagination']?['totalPages'] ?? 1);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
      debugPrint('Erreur chargement publications: $e');
    }
  }

  Future<void> _loadMorePublications() async {
    if (_isLoading || !_hasMore) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken;
    if (token == null) return;

    setState(() => _isLoading = true);

    try {
      final nextPage = _currentPage + 1;
      final result = await ApiService.getPublications(token, page: nextPage, limit: 20);
      if (mounted) {
        final newPubs = result['publications'] ?? [];
        setState(() {
          _publications.addAll(newPubs);
          _currentPage = nextPage;
          _hasMore = (result['pagination']?['currentPage'] ?? nextPage) < (result['pagination']?['totalPages'] ?? nextPage);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Erreur chargement plus de publications: $e');
    }
  }

  Future<void> _likePublication(String publicationId) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken;
    if (token == null) return;

    try {
      await ApiService.toggleLike(token, publicationId);
      // Recharger les publications pour voir le like
      _loadPublications();
    } catch (e) {
      debugPrint('Erreur like publication: $e');
    }
  }

  Future<void> _navigateToCreatePublication() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePublicationPage()),
    );

    // Si une publication a été créée, recharger
    if (result == true) {
      _loadPublications();
    }
  }

  void _showCommentsDialog(String publicationId, String publicationContent) async {
    // Naviguer vers la page des commentaires et attendre le retour
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(
          publicationId: publicationId,
          publicationContent: publicationContent,
        ),
      ),
    );
    
    // Recharger les publications après avoir quitté la page des commentaires
    _loadPublications();
  }

  void _sharePublication(String publicationId) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partage en cours de développement'),
        backgroundColor: Color(0xFF00D4FF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToAllStories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AllStoriesPage(),
      ),
    );
  }

  void _navigateToCreateStory() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken;
    
    if (token == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateStoryPage(token: token),
      ),
    ).then((result) {
      if (result == true) {
        // Recharger les stories si une nouvelle a été créée
        setState(() {});
      }
    });
  }

  Future<void> _navigateToViewStory(int index) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken;
    
    if (token == null) return;
    
    try {
      // Charger les stories depuis l'API
      final result = await ApiService.getStories(token);
      final stories = (result['stories'] as List<dynamic>?)
          ?.map((s) => s as Map<String, dynamic>)
          .toList() ?? [];
      
      if (stories.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune story disponible'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryViewPage(
              token: token,
              stories: stories,
              initialIndex: index < stories.length ? index : 0,
            ),
          ),
        ).then((_) {
          // Recharger les stories après visualisation
          setState(() {});
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFF001122),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(),
              _buildStoriesSection(),
              _buildPostsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bouton Carte
          FloatingActionButton(
            heroTag: 'map',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapViewPage()),
              );
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.map_rounded, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // Bouton Créer Publication
          AnimatedBuilder(
            animation: _fabAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _fabAnimation.value,
                child: FloatingActionButton.extended(
                  heroTag: 'create',
                  onPressed: _navigateToCreatePublication,
                  backgroundColor: const Color(0xFF00D4FF),
                  foregroundColor: Colors.black,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text(
                    'Publier',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Réseau Social',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Connectez-vous avec votre équipe',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFFFF6B35),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Stories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _navigateToAllStories,
                    icon: const Icon(Icons.list_rounded, color: Color(0xFF00D4FF), size: 20),
                    label: const Text(
                      'Voir tout',
                      style: TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: StoryCircle(
                      name: index == 0 ? 'Votre Story' : 'Utilisateur',
                      imageUrl: '',
                      isOwn: index == 0,
                      hasStory: index != 0,
                      onTap: () {
                        if (index == 0) {
                          _navigateToCreateStory();
                        } else {
                          _navigateToViewStory(index);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsSection() {
    if (_isLoading && _publications.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00D4FF),
          ),
        ),
      );
    }

    if (_error != null && _publications.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur: $_error',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPublications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_publications.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'Aucune publication',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= _publications.length) {
              // Loading indicator at bottom
              return _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00D4FF),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            }

            final pub = _publications[index];
            final userId = pub['userId'] ?? {};
            final userName = userId['name'] ?? 'Utilisateur';
            final userEmail = userId['email'] ?? '';
            final content = pub['content'] ?? '';
            final likes = (pub['likes'] as List?)?.length ?? 0;
            final comments = (pub['comments'] as List?)?.length ?? 0;
            final media = pub['media'] as List?;
            
            // Gérer imageUrl (peut être String ou Map)
            String? imageUrl;
            if (media != null && media.isNotEmpty) {
              final firstMedia = media[0];
              if (firstMedia is String) {
                imageUrl = firstMedia;
              } else if (firstMedia is Map) {
                imageUrl = firstMedia['url'] ?? firstMedia['path'];
              }
            }
            
            final createdAt = pub['createdAt'];
            final publicationId = pub['_id'] ?? '';

            // Calculate time ago
            String timeAgo = 'maintenant';
            if (createdAt != null) {
              try {
                final date = DateTime.parse(createdAt);
                final diff = DateTime.now().difference(date);
                if (diff.inDays > 0) {
                  timeAgo = '${diff.inDays}j';
                } else if (diff.inHours > 0) {
                  timeAgo = '${diff.inHours}h';
                } else if (diff.inMinutes > 0) {
                  timeAgo = '${diff.inMinutes}min';
                }
              } catch (e) {
                debugPrint('Erreur parse date: $e');
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PostCard(
                userName: userName,
                userRole: userEmail,
                timeAgo: timeAgo,
                content: content,
                likes: likes,
                comments: comments,
                shares: 0, // Backend doesn't have shares yet
                imageUrl: imageUrl,
                onLike: () => _likePublication(publicationId),
                onComment: () => _showCommentsDialog(publicationId, content),
                onShare: () => _sharePublication(publicationId),
              ),
            );
          },
          childCount: _publications.length + (_isLoading ? 1 : 0),
        ),
      ),
    );
  }
}
