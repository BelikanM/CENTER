import 'dart:math';

/// Gestionnaire centralisé des vidéos aquatiques
class VideoManager {
  static final VideoManager _instance = VideoManager._internal();
  factory VideoManager() => _instance;
  VideoManager._internal();

  final Random _random = Random();

  /// Toutes les vidéos optimisées (< 10 MB)
  static const List<Map<String, dynamic>> _allVideos = [
    {'path': 'assets/videos/aquarium_1.mp4', 'size': 2.94, 'duration': 5, 'brightness': 'medium'},
    {'path': 'assets/videos/aquarium_2.mp4', 'size': 6.53, 'duration': 18, 'brightness': 'light'},
    {'path': 'assets/videos/aquarium_3.mp4', 'size': 8.67, 'duration': 15, 'brightness': 'light'},
    {'path': 'assets/videos/aquarium_4.mp4', 'size': 8.62, 'duration': 35, 'brightness': 'medium'},
    {'path': 'assets/videos/aquarium_6.mp4', 'size': 3.52, 'duration': 17, 'brightness': 'light'},
    {'path': 'assets/videos/aquarium_7.mp4', 'size': 3.22, 'duration': 41, 'brightness': 'medium'},
    {'path': 'assets/videos/aquarium_8.mp4', 'size': 1.03, 'duration': 9, 'brightness': 'light'},
    {'path': 'assets/videos/aquarium_9.mp4', 'size': 1.27, 'duration': 16, 'brightness': 'medium'},
    {'path': 'assets/videos/aquarium_10.mp4', 'size': 1.58, 'duration': 21, 'brightness': 'medium'},
    {'path': 'assets/videos/aquarium_11.mp4', 'size': 1.56, 'duration': 23, 'brightness': 'light'},
    {'path': 'assets/videos/aquarium_12.mp4', 'size': 3.27, 'duration': 12, 'brightness': 'light'},
    {'path': 'assets/videos/aquarium_13.mp4', 'size': 3.32, 'duration': 18, 'brightness': 'medium'},
    {'path': 'assets/videos/aquarium_14.mp4', 'size': 7.03, 'duration': 30, 'brightness': 'medium'},
  ];

  /// Vidéos lumineuses (idéales pour pages claires)
  List<String> get lightVideos => _allVideos
      .where((v) => v['brightness'] == 'light')
      .map((v) => v['path'] as String)
      .toList();

  /// Vidéos moyennes (universelles)
  List<String> get mediumVideos => _allVideos
      .where((v) => v['brightness'] == 'medium')
      .map((v) => v['path'] as String)
      .toList();

  /// Vidéos courtes (< 20s) pour transitions rapides
  List<String> get shortVideos => _allVideos
      .where((v) => (v['duration'] as num) < 20)
      .map((v) => v['path'] as String)
      .toList();

  /// Vidéos longues (> 20s) pour pages statiques
  List<String> get longVideos => _allVideos
      .where((v) => (v['duration'] as num) >= 20)
      .map((v) => v['path'] as String)
      .toList();

  /// Vidéos ultra-légères (< 2 MB) pour performance maximale
  List<String> get ultraLightVideos => _allVideos
      .where((v) => (v['size'] as num) < 2.0)
      .map((v) => v['path'] as String)
      .toList();

  /// Toutes les vidéos disponibles
  List<String> get allVideos => _allVideos
      .map((v) => v['path'] as String)
      .toList();

  /// Obtenir une vidéo aléatoire selon des critères
  String getRandomVideo({
    String brightness = 'any', // 'light', 'medium', 'any'
    String duration = 'any',   // 'short', 'long', 'any'
    bool ultraLight = false,
  }) {
    List<String> candidates = allVideos;

    if (ultraLight) {
      candidates = ultraLightVideos;
    } else {
      // Filtrer par luminosité
      if (brightness == 'light') {
        candidates = lightVideos;
      } else if (brightness == 'medium') {
        candidates = mediumVideos;
      }

      // Filtrer par durée
      if (duration == 'short') {
        candidates = candidates.where((path) {
          final video = _allVideos.firstWhere((v) => v['path'] == path);
          return (video['duration'] as num) < 20;
        }).toList();
      } else if (duration == 'long') {
        candidates = candidates.where((path) {
          final video = _allVideos.firstWhere((v) => v['path'] == path);
          return (video['duration'] as num) >= 20;
        }).toList();
      }
    }

    if (candidates.isEmpty) {
      candidates = allVideos; // Fallback
    }

    return candidates[_random.nextInt(candidates.length)];
  }

  /// Vidéo recommandée pour page d'accueil (longue et universelle)
  String getHomePageVideo() => getRandomVideo(
        brightness: 'any',
        duration: 'long',
      );

  /// Vidéo recommandée pour page d'authentification (calme et lumineuse)
  String getAuthPageVideo() => getRandomVideo(
        brightness: 'light',
        duration: 'any',
      );

  /// Vidéo recommandée pour page sociale (dynamique et courte)
  String getSocialPageVideo() => getRandomVideo(
        brightness: 'medium',
        duration: 'short',
      );

  /// Vidéo recommandée pour page employés (professionnelle et moyenne)
  String getEmployeesPageVideo() => getRandomVideo(
        brightness: 'light',
        duration: 'any',
      );

  /// Vidéo recommandée pour page profil (personnelle et légère)
  String getProfilePageVideo() => getRandomVideo(
        ultraLight: true,
      );

  /// Obtenir une liste de vidéos aléatoires sans répétition
  List<String> getRandomVideos(int count, {String brightness = 'any'}) {
    List<String> candidates = brightness == 'light' 
        ? lightVideos 
        : brightness == 'medium' 
            ? mediumVideos 
            : allVideos;
    
    final shuffled = List<String>.from(candidates)..shuffle(_random);
    return shuffled.take(count.clamp(1, candidates.length)).toList();
  }

  /// Obtenir les informations d'une vidéo
  Map<String, dynamic>? getVideoInfo(String path) {
    try {
      return _allVideos.firstWhere((v) => v['path'] == path);
    } catch (e) {
      return null;
    }
  }
}
