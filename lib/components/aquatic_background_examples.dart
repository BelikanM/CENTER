import 'package:flutter/material.dart';
import '../components/aquatic_background.dart';

/// Exemple d'utilisation du fond aquatique sur la HomePage
/// 
/// Pour activer:
/// 1. Téléchargez une vidéo aquatique (voir AQUATIC_BACKGROUND_GUIDE.md)
/// 2. Placez-la dans: assets/videos/aquarium.mp4
/// 3. Ajoutez dans pubspec.yaml:
///    flutter:
///      assets:
///        - assets/videos/aquarium.mp4
/// 4. Remplacez le build() de HomePage par ce code

class HomePageWithAquaticBackground extends StatelessWidget {
  const HomePageWithAquaticBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaticBackground(
        // Chemin vers votre vidéo aquatique
        videoSource: 'assets/videos/aquarium.mp4',
        isAsset: true,
        
        // Ajustez l'opacité selon vos préférences
        // 0.2 = Très subtil
        // 0.3 = Équilibré (RECOMMANDÉ)
        // 0.5 = Très visible
        opacity: 0.3,
        
        // Ajoute un dégradé noir pour améliorer la lisibilité du texte
        withGradient: true,
        gradientColor: Colors.black,
        
        // Votre contenu existant
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 20 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              // Votre contenu actuel de la HomePage
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              _buildStatsCards(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              // ... etc
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Fond semi-transparent pour contraster avec la vidéo
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tableau de bord',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return const Placeholder(
      fallbackHeight: 200,
      color: Colors.white24,
    );
  }

  Widget _buildQuickActions() {
    return const Placeholder(
      fallbackHeight: 150,
      color: Colors.white24,
    );
  }
}

/// ========================================
/// AUTRES EXEMPLES D'UTILISATION
/// ========================================

/// Exemple 1: AuthPage avec effet océan profond
class AuthPageWithAquaticBackground extends StatelessWidget {
  const AuthPageWithAquaticBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaticBackground(
        videoSource: 'assets/videos/aquarium.mp4',
        isAsset: true,
        opacity: 0.4,
        withGradient: true,
        gradientColor: const Color(0xFF001a33), // Bleu océan foncé
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4FF).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00D4FF),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.waves_rounded,
                    color: Color(0xFF00D4FF),
                    size: 60,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Formulaire de connexion
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Column(
                    children: [
                      // Vos champs de formulaire ici
                      Text(
                        'Connexion',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // ... TextField, etc.
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Exemple 2: SocialPage avec effet subtil
class SocialPageWithAquaticBackground extends StatelessWidget {
  const SocialPageWithAquaticBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaticBackground(
        videoSource: 'assets/videos/aquarium.mp4',
        isAsset: true,
        opacity: 0.2, // Plus subtil pour ne pas distraire des stories
        withGradient: true,
        gradientColor: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              // Header avec stories
              Container(
                height: 120,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Center(
                  child: Text(
                    'Stories',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              // Contenu principal
              const Expanded(
                child: Center(
                  child: Text(
                    'Publications...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Exemple 3: Utiliser une vidéo depuis Internet (pas besoin de télécharger)
class PageWithNetworkAquaticBackground extends StatelessWidget {
  const PageWithNetworkAquaticBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaticBackground(
        // URL directe vers une vidéo en ligne
        videoSource: 'https://example.com/path/to/underwater-video.mp4',
        isAsset: false, // ← IMPORTANT: false pour les URLs réseau
        opacity: 0.3,
        child: const Center(
          child: Text(
            'Contenu de la page',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}

/// Exemple 4: Fond aquatique avec contrôle d'opacité
class PageWithOpacityControl extends StatefulWidget {
  const PageWithOpacityControl({super.key});

  @override
  State<PageWithOpacityControl> createState() => _PageWithOpacityControlState();
}

class _PageWithOpacityControlState extends State<PageWithOpacityControl> {
  double _backgroundOpacity = 0.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaticBackground(
        videoSource: 'assets/videos/aquarium.mp4',
        isAsset: true,
        opacity: _backgroundOpacity,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ajustez l\'intensité du fond',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              // Slider pour contrôler l'opacité
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Opacité:',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          '${(_backgroundOpacity * 100).toInt()}%',
                          style: const TextStyle(
                            color: Color(0xFF00D4FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _backgroundOpacity,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      activeColor: const Color(0xFF00D4FF),
                      inactiveColor: Colors.white24,
                      onChanged: (value) {
                        setState(() => _backgroundOpacity = value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
