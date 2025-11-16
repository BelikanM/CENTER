import 'dart:math';

/// Gestionnaire des patterns de fond pour l'application
class PatternManager {
  static final PatternManager _instance = PatternManager._internal();
  factory PatternManager() => _instance;
  PatternManager._internal();

  // Liste des images de patterns disponibles
  static const List<String> patterns = [
    'patern/pexels-anniroenkae-2983141.jpg',
    'patern/pexels-didsss-2983303.jpg',
    'patern/pexels-hngstrm-1939485.jpg',
    'patern/pexels-ivaoo-691710.jpg',
    'patern/pexels-jibarofoto-3101527.jpg',
    'patern/pexels-joaojesusdesign-925728.jpg',
    'patern/pexels-mdsnmdsnmdsn-1382393.jpg',
  ];

  final Random _random = Random();
  final Map<String, String> _cachedPatterns = {};

  /// Obtenir un pattern aléatoire
  String getRandomPattern() {
    return patterns[_random.nextInt(patterns.length)];
  }

  /// Obtenir un pattern pour une page spécifique (avec cache)
  String getPatternForPage(String pageName) {
    if (_cachedPatterns.containsKey(pageName)) {
      return _cachedPatterns[pageName]!;
    }
    
    final pattern = getRandomPattern();
    _cachedPatterns[pageName] = pattern;
    return pattern;
  }

  /// Obtenir un pattern pour un composant spécifique
  String getPatternForComponent(String componentName) {
    if (_cachedPatterns.containsKey(componentName)) {
      return _cachedPatterns[componentName]!;
    }
    
    final pattern = getRandomPattern();
    _cachedPatterns[componentName] = pattern;
    return pattern;
  }

  /// Réinitialiser le cache (pour changer les patterns)
  void resetCache() {
    _cachedPatterns.clear();
  }

  /// Obtenir un pattern par index (pour tester)
  String getPatternByIndex(int index) {
    if (index < 0 || index >= patterns.length) {
      return patterns[0];
    }
    return patterns[index];
  }
}
