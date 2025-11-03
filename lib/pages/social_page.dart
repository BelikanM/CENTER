import 'package:flutter/material.dart';
import '../components/post_card.dart';
import '../components/story_circle.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
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
    });
  }

  @override
  void dispose() {
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
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: _showCreatePostDialog,
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
                        Text(
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
              child: Text(
                'Stories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: StoryCircle(
                      name: index == 0 ? 'Votre Story' : 'Utilisateur ${index + 1}',
                      imageUrl: '',
                      isOwn: index == 0,
                      hasStory: index != 0,
                      onTap: () {
                        if (index == 0) {
                          _showCreateStoryDialog();
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
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PostCard(
                userName: 'Marie Dubois',
                userRole: 'Développeuse Senior',
                timeAgo: '${index + 1}h',
                content: _getPostContent(index),
                likes: (index + 1) * 12,
                comments: (index + 1) * 3,
                shares: index + 1,
                imageUrl: index % 3 == 0 ? 'https://picsum.photos/400/300?random=$index' : null,
                onLike: () {},
                onComment: () {},
                onShare: () {},
              ),
            );
          },
          childCount: 10,
        ),
      ),
    );
  }

  String _getPostContent(int index) {
    final contents = [
      'Excellente réunion d\'équipe aujourd\'hui ! Nous avons fait de grands progrès sur le nouveau projet. 🚀',
      'Merci à toute l\'équipe pour le travail acharné cette semaine. Les résultats parlent d\'eux-mêmes ! 💪',
      'Nouvelle fonctionnalité déployée avec succès ! Les utilisateurs vont adorer cette mise à jour.',
      'Formation sur les nouvelles technologies terminée. Toujours excitant d\'apprendre de nouvelles choses ! 📚',
      'Belle collaboration avec l\'équipe design aujourd\'hui. Le nouveau design est incroyable ! 🎨',
      'Code review terminé ! Merci à tous pour vos commentaires constructifs.',
      'Pause café bien méritée après cette intense session de debugging ! ☕',
      'Les tests automatisés fonctionnent parfaitement. Qualité code au top ! ✅',
      'Sprint terminé avec succès ! Prêts pour le prochain challenge.',
      'Brainstorming productif pour les prochaines fonctionnalités. Des idées brillantes ! 💡',
    ];
    return contents[index % contents.length];
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'Créer une publication',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Publier',
                          style: TextStyle(
                            color: Color(0xFF00D4FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Que voulez-vous partager ?',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  _buildPostOption(Icons.image_rounded, 'Photo'),
                  const SizedBox(width: 24),
                  _buildPostOption(Icons.videocam_rounded, 'Vidéo'),
                  const SizedBox(width: 24),
                  _buildPostOption(Icons.location_on_rounded, 'Lieu'),
                  const SizedBox(width: 24),
                  _buildPostOption(Icons.poll_rounded, 'Sondage'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateStoryDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Créer une Story',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStoryOption(Icons.camera_alt_rounded, 'Photo', const Color(0xFF00D4FF)),
                _buildStoryOption(Icons.videocam_rounded, 'Vidéo', const Color(0xFFFF6B35)),
                _buildStoryOption(Icons.text_fields_rounded, 'Texte', const Color(0xFF9C27B0)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPostOption(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.7),
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStoryOption(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
