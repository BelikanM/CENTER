# 🐠 Dossier des vidéos d'arrière-plan

## 📥 Comment ajouter une vidéo aquatique

### Méthode 1 : Téléchargement manuel (RECOMMANDÉ)

1. **Visitez Pexels** : https://www.pexels.com/search/videos/underwater%20fish/

2. **Choisissez une vidéo** (exemples recommandés) :
   - Aquarium with tropical fish
   - Underwater coral reef
   - Fish swimming in ocean
   - Jellyfish floating

3. **Téléchargez** :
   - Cliquez sur la vidéo
   - Cliquez "Free Download"
   - Choisissez **HD 720p** (≈5 MB) ou **SD** (≈2 MB)

4. **Renommez et placez** :
   - Renommez en : `aquarium.mp4`
   - Placez dans ce dossier (`assets/videos/`)

### Méthode 2 : Script automatique

Exécutez depuis la racine du projet :
```powershell
.\download_aquatic_video.ps1
```

## 📝 Vidéos recommandées

### Top 3 vidéos gratuites :

1. **Aquarium relaxant** ⭐ (MEILLEUR CHOIX)
   - URL : https://www.pexels.com/video/fish-swimming-in-an-aquarium-3044413/
   - Durée : 15s
   - Qualité : HD (720p ≈5 MB)
   - Ambiance : Calme, coloré

2. **Bancs de poissons tropicaux**
   - URL : https://www.pexels.com/video/schools-of-fish-underwater-7989441/
   - Durée : 12s
   - Qualité : HD
   - Ambiance : Dynamique

3. **Coraux et poissons**
   - URL : https://www.pexels.com/video/colorful-fishes-swimming-underwater-5530356/
   - Durée : 20s
   - Qualité : HD
   - Ambiance : Tropical, vibrant

## ✅ Vérification

Une fois la vidéo ajoutée, vérifiez que :
- [x] Le fichier est bien nommé `aquarium.mp4`
- [x] Il est dans `assets/videos/aquarium.mp4`
- [x] La taille est < 10 MB (idéal : 5 MB)
- [x] Le format est MP4 (H.264)

## 🚀 Utilisation

Après avoir ajouté la vidéo :

```dart
import 'package:flutter/material.dart';
import '../components/aquatic_background.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaticBackground(
        videoSource: 'assets/videos/aquarium.mp4',
        isAsset: true,
        opacity: 0.3,
        child: // Votre contenu
      ),
    );
  }
}
```

## 🔧 Optimisation (optionnel)

Si la vidéo est trop lourde (> 10 MB), compressez-la :

**En ligne** :
- https://www.freeconvert.com/video-compressor
- https://www.online-convert.com/

**Paramètres** :
- Résolution : 720p (1280x720)
- Bitrate : 2 Mbps
- FPS : 24 ou 30

## 📚 Documentation complète

Voir le fichier `AQUATIC_BACKGROUND_GUIDE.md` à la racine du projet pour :
- Guide d'installation détaillé
- Exemples d'utilisation
- Personnalisation avancée
- Résolution de problèmes
