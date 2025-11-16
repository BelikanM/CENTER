import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../api_service.dart';
import '../theme/theme_provider.dart';
import '../components/futuristic_card.dart';
import '../components/stats_card.dart';
import '../components/quick_action_card.dart';
import '../components/image_background.dart';
import '../utils/background_image_manager.dart';
import 'social_page.dart';
import 'map_view_page.dart';
import 'admin_page.dart';
import 'notifications_list_page.dart';
import 'create/create_employee_page.dart';
import 'comments_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late String _selectedImage;
  final BackgroundImageManager _imageManager = BackgroundImageManager();

  // Statistiques dynamiques
  bool _isLoadingStats = false;
  int _employeesCount = 0;
  int _publicationsCount = 0;
  int _markersCount = 0;
  int _notificationsCount = 0;
  
  // Publications récentes pour les commentaires
  List<Map<String, dynamic>> _recentPublications = [];
  bool _isLoadingPublications = false;

  @override
  void initState() {
    super.initState();
    // Sélectionner une image aléatoire au démarrage
    _selectedImage = _imageManager.getImageForPage('home');

    // Charger les statistiques et les publications récentes
    _loadStats();
    _loadRecentPublications();
  }

  /// Charger toutes les statistiques depuis l'API
  Future<void> _loadStats() async {
    if (!mounted) return;
    
    setState(() => _isLoadingStats = true);
    
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final token = appProvider.accessToken;
      
      if (token == null) return;

      // Charger les statistiques globales
      try {
        final statsResult = await ApiService.getStats(token);
        if (mounted) {
          setState(() {
            // L'API retourne stats.employees.total, stats.publications.total, etc.
            _employeesCount = statsResult['employees']?['total'] ?? 0;
            _publicationsCount = statsResult['publications']?['total'] ?? 0;
            _markersCount = statsResult['markers']?['total'] ?? 0;
          });
        }
      } catch (e) {
        debugPrint('❌ Erreur chargement stats: $e');
      }

      // Charger les notifications
      try {
        final notifsResult = await ApiService.getNotifications(token);
        if (notifsResult['success'] == true && mounted) {
          setState(() {
            _notificationsCount = notifsResult['unreadCount'] ?? 0;
          });
        }
      } catch (e) {
        debugPrint('❌ Erreur chargement notifications: $e');
      }

    } finally {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  /// Charger les publications récentes pour la section commentaires
  Future<void> _loadRecentPublications() async {
    if (!mounted) return;
    
    setState(() => _isLoadingPublications = true);
    
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final token = appProvider.accessToken;
      
      if (token == null) return;

      // Charger les publications récentes de tous les utilisateurs
      try {
        final result = await ApiService.getPublications(token, page: 1, limit: 5);
        debugPrint('📊 Publications reçues: $result');
        
        if (mounted && result['success'] == true) {
          final pubs = result['publications'] as List? ?? [];
          debugPrint('✅ Nombre de publications: ${pubs.length}');
          
          setState(() {
            _recentPublications = pubs.take(5).map((p) => p as Map<String, dynamic>).toList();
          });
          
          debugPrint('✅ Publications chargées: $_recentPublications');
        } else {
          debugPrint('⚠️ Résultat invalide ou pas de succès');
        }
      } catch (e) {
        debugPrint('❌ Erreur chargement publications récentes: $e');
      }

    } finally {
      if (mounted) {
        setState(() => _isLoadingPublications = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: ImageBackground(
        imagePath: _selectedImage,
        opacity: 0.30,
        withGradient: false,
        child: RefreshIndicator(
          onRefresh: _loadStats,
          color: themeProvider.primaryColor,
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildWelcomeSection(),
                      const SizedBox(height: 32),
                      _buildStatsSection(),
                      const SizedBox(height: 32),
                      _buildQuickActions(),
                      const SizedBox(height: 32),
                      _buildRecentPublications(),
                      SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SliverAppBar(
          expandedHeight: 120,
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
                    themeProvider.surfaceColor,
                    themeProvider.surfaceColor.withValues(alpha: 0.9),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      // Logo SETRAF dans un cercle avec badge de notification
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: themeProvider.gradient,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Badge de notification style TikTok/Facebook
                          if (_notificationsCount > 0)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [themeProvider.secondaryColor, themeProvider.accentColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: themeProvider.surfaceColor,
                                    width: 2.5,
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 22,
                                  minHeight: 22,
                                ),
                                child: Text(
                                  _notificationsCount > 99 ? '99+' : _notificationsCount.toString(),
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tableau de bord',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Vue d\'ensemble de votre activité',
                              style: TextStyle(
                                color: themeProvider.textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bouton notifications avec badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsListPage(),
                                ),
                              ).then((_) {
                                // Recharger les stats après retour de la page notifications
                                _loadStats();
                              });
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: themeProvider.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: themeProvider.primaryColor,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.notifications_rounded,
                                color: themeProvider.primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                          // Badge avec le nombre de notifications (style moderne)
                          if (_notificationsCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [themeProvider.secondaryColor, themeProvider.accentColor],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: themeProvider.surfaceColor,
                                    width: 2,
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Text(
                                  _notificationsCount > 99 ? '99+' : _notificationsCount.toString(),
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final user = appProvider.currentUser;
        final userName = user?['name'] ?? 'Utilisateur';
        final userAvatar = user?['profileImage'];
        
        // Vérifier si l'avatar contient déjà l'URL complète ou juste le chemin
        final avatarUrl = userAvatar != null && userAvatar.isNotEmpty
            ? (userAvatar.startsWith('http') 
                ? userAvatar // URL complète déjà présente
                : '${ApiService.baseUrl}$userAvatar') // Ajouter baseUrl si nécessaire
            : null;
        
        // Debug: afficher les infos utilisateur
        debugPrint('👤 User info: name=$userName, avatar=$avatarUrl');
        
        return FuturisticCard(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour,',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF00FF88), Color(0xFF00CC66)],
                        ).createShader(bounds),
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Prêt à conquérir cette journée ?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: avatarUrl == null
                        ? const LinearGradient(
                            colors: [Color(0xFF00FF88), Color(0xFF00CC66)],
                          )
                        : null,
                    image: avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(avatarUrl),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              debugPrint('❌ Erreur chargement avatar: $exception');
                            },
                          )
                        : null,
                  ),
                  child: avatarUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Statistiques en temps réel',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_isLoadingStats)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Employés',
                    value: _employeesCount.toString(),
                    icon: Icons.groups_rounded,
                    color: themeProvider.primaryColor,
                    trend: '+12%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatsCard(
                    title: 'Publications',
                    value: _publicationsCount.toString(),
                    icon: Icons.article_rounded,
                    color: themeProvider.secondaryColor,
                    trend: '+8%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Marqueurs',
                    value: _markersCount.toString(),
                    icon: Icons.location_on_rounded,
                    color: themeProvider.accentColor,
                    trend: '+3%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatsCard(
                    title: 'Notifications',
                    value: _notificationsCount.toString(),
                    icon: Icons.notifications_rounded,
                    color: themeProvider.primaryColor,
                    trend: _notificationsCount > 0 ? 'Nouvelles!' : '',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final user = appProvider.currentUser;
        final isAdmin = user?['role'] == 'admin' || user?['isAdmin'] == true;
        
        // Liste de toutes les actions
        final List<Widget> actions = [
          // Action pour tout le monde: Publier Contenu
          QuickActionCard(
            title: 'Publier\nContenu',
            icon: Icons.edit_rounded,
            color: const Color(0xFF00CC66),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SocialPage()),
              );
            },
          ),
          // Action pour tout le monde: Ajouter Marqueur
          QuickActionCard(
            title: 'Ajouter\nMarqueur',
            icon: Icons.add_location_rounded,
            color: const Color(0xFF009944),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapViewPage()),
              );
            },
          ),
        ];

        // Ajouter les actions admin seulement si l'utilisateur est admin
        if (isAdmin) {
          actions.insertAll(0, [
            QuickActionCard(
              title: 'Nouveau\nEmployé',
              icon: Icons.person_add_rounded,
              color: const Color(0xFF00FF88),
              onTap: () {
                final token = appProvider.accessToken;
                if (token != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateEmployeePage()),
                  ).then((_) => _loadStats());
                }
              },
            ),
          ]);
          
          actions.add(
            QuickActionCard(
              title: 'Rapport\nAnalyse',
              icon: Icons.analytics_rounded,
              color: const Color(0xFF00FF88),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPage()),
                );
              },
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: actions,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentPublications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Publications récentes',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_recentPublications.isNotEmpty)
              TextButton.icon(
                onPressed: _loadRecentPublications,
                icon: Icon(
                  Icons.refresh,
                  color: Color(0xFF00D4FF),
                  size: 18,
                ),
                label: Text(
                  'Actualiser',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        FuturisticCard(
          child: _isLoadingPublications
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00D4FF),
                    ),
                  ),
                )
              : _recentPublications.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 48,
                              color: Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune publication',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadRecentPublications,
                              child: Text(
                                'Réessayer',
                                style: TextStyle(color: Color(0xFF00D4FF)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _recentPublications.asMap().entries.map((entry) {
                        final index = entry.key;
                        final publication = entry.value;
                        
                        final publicationId = publication['_id'] ?? 'unknown';
                        final content = publication['content'] ?? publication['text'] ?? '';
                        final userId = publication['userId'];
                        final userName = userId is Map ? userId['name'] ?? 'Utilisateur' : 'Utilisateur';
                        final profileImage = userId is Map ? userId['profileImage'] ?? '' : '';
                        final media = publication['media'] as List? ?? [];
                        final hasMedia = media.isNotEmpty;
                        final firstMedia = hasMedia ? media[0] as Map<String, dynamic> : null;
                        final mediaType = firstMedia?['type'] ?? '';
                        final mediaUrl = firstMedia?['url'] ?? '';
                        final commentsCount = (publication['comments'] as List?)?.length ?? 0;
                        final likesCount = (publication['likes'] as List?)?.length ?? 0;
                        final createdAt = publication['createdAt'] != null
                            ? DateTime.parse(publication['createdAt'])
                            : DateTime.now();
                        final timeAgo = _formatTimeAgo(createdAt);

                        return Column(
                          children: [
                            if (index > 0) Divider(color: Colors.black.withValues(alpha: 0.1), height: 1),
                            InkWell(
                              onTap: () {
                                debugPrint('🔗 Navigation vers publication: $publicationId');
                                // Ouvrir la page de commentaires
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommentsPage(
                                      publicationId: publicationId,
                                      publicationContent: content,
                                    ),
                                  ),
                                ).then((_) {
                                  // Actualiser après le retour
                                  _loadRecentPublications();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Avatar utilisateur
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: profileImage.isNotEmpty
                                          ? NetworkImage(profileImage)
                                          : null,
                                      backgroundColor: const Color(0xFF00D4FF),
                                      child: profileImage.isEmpty
                                          ? const Icon(Icons.person, size: 20, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    // Contenu principal
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // En-tête: nom et temps
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  userName,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                timeAgo,
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Texte de la publication
                                          if (content.isNotEmpty)
                                            Text(
                                              content,
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                                height: 1.4,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          // Aperçu média si présent
                                          if (hasMedia) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              height: 120,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: Colors.black12,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    if (mediaType == 'image' && mediaUrl.isNotEmpty)
                                                      Image.network(
                                                        mediaUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => Icon(
                                                          Icons.broken_image,
                                                          color: Colors.black26,
                                                        ),
                                                      )
                                                    else if (mediaType == 'video')
                                                      Container(
                                                        color: Colors.black87,
                                                        child: Icon(
                                                          Icons.play_circle_outline,
                                                          size: 48,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    else
                                                      Icon(
                                                        Icons.image,
                                                        color: Colors.black26,
                                                      ),
                                                    if (media.length > 1)
                                                      Positioned(
                                                        top: 8,
                                                        right: 8,
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.black54,
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: Text(
                                                            '+${media.length - 1}',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          // Actions (likes, commentaires)
                                          Row(
                                            children: [
                                              if (likesCount > 0) ...[
                                                Icon(Icons.favorite, size: 16, color: Colors.red),
                                                const SizedBox(width: 4),
                                                Text(
                                                  likesCount.toString(),
                                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                                ),
                                                const SizedBox(width: 16),
                                              ],
                                              Icon(
                                                Icons.chat_bubble_outline,
                                                size: 16,
                                                color: Color(0xFF00D4FF),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                commentsCount > 0 
                                                    ? '$commentsCount ${commentsCount > 1 ? "commentaires" : "commentaire"}'
                                                    : 'Commenter',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF00D4FF),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Spacer(),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.black38,
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
        ),
      ],
    );
  }

  /// Formater le temps écoulé
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return 'Il y a ${(difference.inDays / 7).floor()}sem';
    }
  }
}
