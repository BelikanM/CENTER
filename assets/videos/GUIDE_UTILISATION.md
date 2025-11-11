# Guide d'utilisation des videos aquatiques

## Videos disponibles

Vous avez maintenant 15 videos aquatiques dans `assets/videos/` :

### Videos OK (< 10 MB) - PRETS A L'EMPLOI
- `aquarium_1.mp4` - 2.94 MB  ✅ RECOMMANDE
- `aquarium_2.mp4` - 6.53 MB  ✅ RECOMMANDE
- `aquarium_3.mp4` - 8.67 MB  ✅ RECOMMANDE

### Videos trop volumineuses (> 10 MB) - A compresser
- `aquarium_4.mp4` à `aquarium_15.mp4` (14-133 MB)

## Utilisation immediat

### 1. Dans votre HomePage

```dart
import '../components/aquatic_background.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: AquaticBackground(
      videoSource: 'assets/videos/aquarium_1.mp4', // ← La plus petite
      isAsset: true,
      opacity: 0.3,
      child: SafeArea(
        child: // Votre contenu actuel
      ),
    ),
  );
}
```

### 2. Dans l'AuthPage

```dart
AquaticBackground(
  videoSource: 'assets/videos/aquarium_2.mp4',
  isAsset: true,
  opacity: 0.4,
  gradientColor: const Color(0xFF001a33), // Bleu ocean
  child: // Votre formulaire de connexion
)
```

### 3. Dans la SocialPage

```dart
AquaticBackground(
  videoSource: 'assets/videos/aquarium_3.mp4',
  isAsset: true,
  opacity: 0.2, // Plus subtil
  child: // Vos stories et publications
)
```

## Rotation aleatoire

Pour varier les videos a chaque demarrage :

```dart
import 'dart:math';

class HomePage extends StatelessWidget {
  // Liste des videos OK
  final _videos = [
    'assets/videos/aquarium_1.mp4',
    'assets/videos/aquarium_2.mp4',
    'assets/videos/aquarium_3.mp4',
  ];
  
  @override
  Widget build(BuildContext context) {
    // Choisir une video aleatoire
    final randomVideo = _videos[Random().nextInt(_videos.length)];
    
    return Scaffold(
      body: AquaticBackground(
        videoSource: randomVideo,
        isAsset: true,
        opacity: 0.3,
        child: // Votre contenu
      ),
    );
  }
}
```

## Compression des autres videos

Les videos 4 a 15 sont trop volumineuses. Options :

### Option 1 : Utiliser seulement les 3 premieres (RECOMMANDE)
- Gardez uniquement `aquarium_1.mp4`, `aquarium_2.mp4`, `aquarium_3.mp4`
- Supprimez les autres pour economiser l'espace

### Option 2 : Compresser avec Python
Une fois OpenCV installe :
```powershell
python compress_videos_opencv.py
```

### Option 3 : Compresser en ligne
1. Allez sur : https://www.freeconvert.com/video-compressor
2. Uploadez `aquarium_4.mp4`, `aquarium_5.mp4`, etc.
3. Choisissez "Target size: 9 MB"
4. Telechargez et remplacez

### Option 4 : Supprimer les videos volumineuses
```powershell
cd assets/videos
Remove-Item aquarium_4.mp4, aquarium_5.mp4, aquarium_6.mp4, aquarium_7.mp4, aquarium_8.mp4, aquarium_9.mp4, aquarium_10.mp4, aquarium_11.mp4, aquarium_12.mp4, aquarium_13.mp4, aquarium_14.mp4, aquarium_15.mp4
```

## Exemple complet - HomePage avec fond aquatique

```dart
import 'package:flutter/material.dart';
import '../components/aquatic_background.dart';
import '../components/futuristic_card.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaticBackground(
        videoSource: 'assets/videos/aquarium_1.mp4',
        isAsset: true,
        opacity: 0.3,
        withGradient: true,
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
              // Header
              FuturisticCard(
                child: Container(
                  padding: EdgeInsets.all(24),
                  child: Column(
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
                        'Votre espace aquatique',
                        style: TextStyle(
                          color: Color(0xFF00D4FF),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Votre contenu existant...
            ],
          ),
        ),
      ),
    );
  }
}
```

## Personnalisation

### Changer l'opacite
```dart
opacity: 0.2, // Tres subtil
opacity: 0.3, // Equilibre (RECOMMANDE)
opacity: 0.5, // Tres visible
```

### Changer la couleur du degrade
```dart
gradientColor: Colors.black, // Par defaut
gradientColor: const Color(0xFF001a33), // Bleu ocean
gradientColor: const Color(0xFF1a0033), // Violet profond
```

### Desactiver le degrade
```dart
withGradient: false, // Video pure sans overlay
```

## Performance

Pour de meilleures performances :
- Utilisez `aquarium_1.mp4` (la plus legere)
- Gardez `opacity` entre 0.2 et 0.3
- Ajoutez `RepaintBoundary` autour du contenu

```dart
AquaticBackground(
  videoSource: 'assets/videos/aquarium_1.mp4',
  isAsset: true,
  opacity: 0.3,
  child: RepaintBoundary(
    child: // Votre contenu
  ),
)
```

## Prochaines etapes

1. ✅ Les 3 premieres videos sont pretes !
2. ⏳ Attendez que Python/OpenCV termine l'installation
3. 🚀 Lancez `python compress_videos_opencv.py` pour les autres
4. 🎨 Testez avec `flutter run`
