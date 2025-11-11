# 🐠 Guide d'installation du fond vidéo aquatique

## Étape 1 : Télécharger une vidéo

### Liens directs recommandés :

**Option 1 - Aquarium relaxant (RECOMMANDÉ)** :
- https://www.pexels.com/video/fish-swimming-in-an-aquarium-3044413/
- Durée : 15s
- Qualité : HD
- Taille : ~5 MB

**Option 2 - Océan avec poissons** :
- https://www.pexels.com/video/schools-of-fish-underwater-7989441/
- Durée : 12s
- Qualité : HD

**Option 3 - Coraux et poissons tropicaux** :
- https://www.pexels.com/video/colorful-fishes-swimming-underwater-5530356/
- Durée : 20s
- Qualité : HD

## Étape 2 : Ajouter la vidéo au projet

1. **Créer le dossier assets/videos** dans votre projet :
   ```
   CENTER/
   ├── assets/
   │   └── videos/
   │       └── aquarium.mp4  ← Placez votre vidéo ici
   ├── lib/
   └── pubspec.yaml
   ```

2. **Renommer la vidéo** : Appelez-la `aquarium.mp4` (ou un autre nom simple)

3. **Déclarer dans pubspec.yaml** :
   ```yaml
   flutter:
     assets:
       - assets/videos/aquarium.mp4
       # Ou pour inclure tous les fichiers du dossier :
       # - assets/videos/
   ```

## Étape 3 : Utilisation

### Exemple 1 - HomePage avec fond aquatique

```dart
import '../components/aquatic_background.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: AquaticBackground(
      videoSource: 'assets/videos/aquarium.mp4',
      isAsset: true,
      opacity: 0.3, // Ajustez entre 0.2 et 0.5
      withGradient: true,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Votre contenu ici
          ],
        ),
      ),
    ),
  );
}
```

### Exemple 2 - AuthPage avec effet océan

```dart
AquaticBackground(
  videoSource: 'assets/videos/aquarium.mp4',
  isAsset: true,
  opacity: 0.4,
  gradientColor: const Color(0xFF001a33), // Bleu océan
  child: // Votre formulaire de connexion
)
```

### Exemple 3 - Utiliser une vidéo en ligne (sans téléchargement)

```dart
AquaticBackground(
  videoSource: 'https://example.com/underwater.mp4',
  isAsset: false, // ← Important !
  opacity: 0.3,
  child: // Votre contenu
)
```

## Étape 4 : Optimisation

### Réduire la taille de la vidéo

Si la vidéo est trop lourde (> 10 MB), utilisez **HandBrake** ou un outil en ligne :

**En ligne** :
- https://www.freeconvert.com/video-compressor
- https://www.online-convert.com/

**Paramètres recommandés** :
- Résolution : 720p (1280x720)
- Bitrate : 2 Mbps
- Format : MP4 (H.264)
- FPS : 24 ou 30

### Performance

Pour améliorer les performances :

```dart
AquaticBackground(
  videoSource: 'assets/videos/aquarium.mp4',
  isAsset: true,
  opacity: 0.25, // ← Réduit légèrement
  withGradient: true,
  child: RepaintBoundary( // ← Isoler le contenu
    child: // Votre contenu
  ),
)
```

## Personnalisation avancée

### Changer l'opacité dynamiquement

```dart
class _HomePageState extends State<HomePage> {
  double _backgroundOpacity = 0.3;
  
  @override
  Widget build(BuildContext context) {
    return AquaticBackground(
      opacity: _backgroundOpacity,
      // ...
      child: Column(
        children: [
          Slider(
            value: _backgroundOpacity,
            onChanged: (value) => setState(() => _backgroundOpacity = value),
            min: 0.0,
            max: 1.0,
          ),
          // Reste du contenu
        ],
      ),
    );
  }
}
```

### Différentes vidéos selon la page

```dart
// HomePage : aquarium calme
AquaticBackground(
  videoSource: 'assets/videos/aquarium.mp4',
  opacity: 0.3,
  child: // ...
)

// SocialPage : océan dynamique
AquaticBackground(
  videoSource: 'assets/videos/ocean.mp4',
  opacity: 0.25,
  child: // ...
)
```

## Exemples de pages à modifier

### 1. HomePage (Accueil)
```dart
// Remplacer le Container avec gradient par :
AquaticBackground(
  videoSource: 'assets/videos/aquarium.mp4',
  isAsset: true,
  opacity: 0.3,
  child: SafeArea(
    child: ListView(
      // Votre contenu actuel
    ),
  ),
)
```

### 2. AuthPage (Connexion)
```dart
AquaticBackground(
  videoSource: 'assets/videos/aquarium.mp4',
  isAsset: true,
  opacity: 0.4,
  gradientColor: const Color(0xFF0A0A0A),
  child: // Formulaires de connexion
)
```

### 3. SocialPage (Stories)
```dart
AquaticBackground(
  videoSource: 'assets/videos/ocean.mp4',
  isAsset: true,
  opacity: 0.2, // Plus subtil pour cette page
  child: // Contenu social
)
```

## Troubleshooting

### La vidéo ne s'affiche pas ?
1. Vérifiez que le fichier est bien dans `assets/videos/`
2. Vérifiez `pubspec.yaml` (bien indenté)
3. Redémarrez l'app (`flutter run`)
4. Videz le cache : `flutter clean`

### La vidéo lag ?
1. Réduisez la résolution (720p maximum)
2. Compressez la vidéo (< 5 MB idéal)
3. Réduisez l'opacité
4. Utilisez `RepaintBoundary` pour le contenu

### Erreur "Failed to load video" ?
1. Vérifiez le chemin (sensible à la casse)
2. Format supporté : MP4 (H.264)
3. Testez avec une vidéo plus petite d'abord

## Ressources supplémentaires

**Vidéos gratuites** :
- Pexels : https://www.pexels.com/videos/
- Pixabay : https://pixabay.com/videos/
- Videezy : https://www.videezy.com/

**Outils de compression** :
- HandBrake : https://handbrake.fr/ (gratuit, desktop)
- FFmpeg : https://ffmpeg.org/ (ligne de commande)
- CloudConvert : https://cloudconvert.com/ (en ligne)

**Inspiration** :
- Recherchez "aquarium screensaver" sur YouTube
- Recherchez "underwater 4k loop" pour des options HD
