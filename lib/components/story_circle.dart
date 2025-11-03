import 'package:flutter/material.dart';

class StoryCircle extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isOwn;
  final bool hasStory;
  final VoidCallback onTap;

  const StoryCircle({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.isOwn,
    required this.hasStory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 32,
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
