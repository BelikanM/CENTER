import 'package:flutter/material.dart';

class StoryCircle extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isOwn;
  final bool hasStory;
  final VoidCallback onTap;
  final String? mediaUrl; // URL de la vidéo ou image de la story
  final String? mediaType; // 'video', 'image', ou 'text'

  const StoryCircle({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.isOwn,
    required this.hasStory,
    required this.onTap,
    this.mediaUrl,
    this.mediaType,
  });

  @override
  Widget build(BuildContext context) {
    // Déterminer quelle image afficher en fond
    String backgroundImage = imageUrl;
    
    // Si c'est une story avec une image, utiliser l'image de la story
    if (hasStory && !isOwn && mediaType == 'image' && mediaUrl != null && mediaUrl!.isNotEmpty) {
      backgroundImage = mediaUrl!;
    }
    // Si c'est une vidéo, on pourrait extraire un thumbnail mais pour l'instant on garde le profile
    else if (hasStory && !isOwn && mediaType == 'video') {
      // On garde l'image de profil pour les vidéos
      backgroundImage = imageUrl;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasStory || isOwn
                      ? const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFFFF6B35)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: !hasStory && !isOwn
                      ? Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        )
                      : null,
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2A2A2A),
                    image: backgroundImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(backgroundImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: backgroundImage.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 32,
                        )
                      : mediaType == 'video' && hasStory && !isOwn
                          // Icône play pour les vidéos
                          ? Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            )
                          : null,
                ),
              ),
              if (isOwn)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
