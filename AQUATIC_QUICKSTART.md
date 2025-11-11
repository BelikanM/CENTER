# 🐠 Résumé Ultra-Rapide - Fond Vidéo Aquatique

## ⚡ Installation en 3 étapes

### 1️⃣ Télécharger une vidéo
**Option rapide** : https://www.pexels.com/video/fish-swimming-in-an-aquarium-3044413/
- Cliquez sur "Free Download" → Choisissez "HD 720p" (≈5 MB)
- Enregistrez dans : `assets/videos/aquarium.mp4`

### 2️⃣ Modifier `pubspec.yaml`
```yaml
flutter:
  assets:
    - assets/videos/aquarium.mp4
```

### 3️⃣ Utiliser dans votre page
```dart
import '../components/aquatic_background.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: AquaticBackground(
      videoSource: 'assets/videos/aquarium.mp4',
      isAsset: true,
      opacity: 0.3, // 0.2 = subtil, 0.5 = visible
      child: SafeArea(
        child: // Votre contenu existant
      ),
    ),
  );
}
```

## 🎯 Où l'appliquer ?

| Page | Opacité recommandée | Effet |
|------|---------------------|-------|
| **HomePage** | 0.3 | Accueillant, dynamique |
| **AuthPage** | 0.4 | Immersif, professionnel |
| **SocialPage** | 0.2 | Subtil, ne distrait pas |
| **ProfilePage** | 0.25 | Élégant, discret |

## 📦 Fichiers créés

✅ `lib/components/aquatic_background.dart` - Widget principal
✅ `lib/components/aquatic_background_examples.dart` - Exemples d'utilisation
✅ `AQUATIC_BACKGROUND_GUIDE.md` - Guide détaillé
✅ `download_aquatic_video.ps1` - Script de téléchargement

## 🔧 Commandes utiles

```powershell
# Télécharger automatiquement (si configuré)
.\download_aquatic_video.ps1

# Nettoyer et reconstruire
flutter clean
flutter pub get
flutter run
```

## 🎨 Personnalisation rapide

### Changer l'opacité
```dart
opacity: 0.3, // Plus bas = plus subtil
```

### Changer la couleur du dégradé
```dart
gradientColor: const Color(0xFF001a33), // Bleu océan
gradientColor: const Color(0xFF000000), // Noir (par défaut)
gradientColor: const Color(0xFF1a0033), // Violet profond
```

### Désactiver le dégradé
```dart
withGradient: false, // Vidéo pure sans overlay
```

### Utiliser une vidéo en ligne
```dart
videoSource: 'https://example.com/video.mp4',
isAsset: false, // ← Important !
```

## 🐛 Dépannage Express

**Vidéo ne s'affiche pas ?**
```bash
flutter clean
flutter pub get
flutter run
```

**Vidéo lag ?**
- Compressez à 720p max
- Réduisez opacity à 0.2
- Utilisez une vidéo < 5 MB

**Erreur "asset not found" ?**
- Vérifiez le chemin dans `pubspec.yaml`
- Redémarrez l'app après modification

## 🌟 Exemple complet (HomePage)

```dart
import 'package:flutter/material.dart';
import '../components/aquatic_background.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaticBackground(
        videoSource: 'assets/videos/aquarium.mp4',
        isAsset: true,
        opacity: 0.3,
        withGradient: true,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Bienvenue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Votre contenu existant...
            ],
          ),
        ),
      ),
    );
  }
}
```

## 📚 Plus d'infos
Voir `AQUATIC_BACKGROUND_GUIDE.md` pour le guide complet
