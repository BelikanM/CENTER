import 'package:flutter/material.dart';

/// Widget compact pour afficher les stats de partage à côté du compteur
class ShareStatsWidget extends StatelessWidget {
  final int shareCount;
  final int? visitCount;
  final VoidCallback onTap;

  const ShareStatsWidget({
    super.key,
    required this.shareCount,
    this.visitCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF00FF88).withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône partage
            const Icon(
              Icons.share_rounded,
              color: Color(0xFF00FF88),
              size: 14,
            ),
            const SizedBox(width: 4),
            
            // Nombre de partages
            Text(
              '$shareCount',
              style: const TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            if (visitCount != null && visitCount! > 0) ...[
              const SizedBox(width: 6),
              Container(
                width: 1,
                height: 12,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 6),
              
              // Mini graphique (barres verticales)
              _buildMiniChart(visitCount!),
              
              const SizedBox(width: 4),
              
              // Nombre de visites
              Text(
                '$visitCount',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
            
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChart(int visits) {
    // Créer 3 barres de hauteurs variables basées sur le nombre de visites
    final maxHeight = 12.0;
    final heights = _calculateBarHeights(visits, maxHeight);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBar(heights[0], const Color(0xFF00D4FF)),
        const SizedBox(width: 2),
        _buildBar(heights[1], const Color(0xFF00FF88)),
        const SizedBox(width: 2),
        _buildBar(heights[2], const Color(0xFFFF6B9D)),
      ],
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 2,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  List<double> _calculateBarHeights(int visits, double maxHeight) {
    // Simuler des hauteurs variables basées sur le nombre total
    if (visits == 0) return [2.0, 2.0, 2.0];
    
    // Utiliser une distribution simple
    final base = (visits % 10) / 10 * maxHeight;
    return [
      (base + 4).clamp(4.0, maxHeight),
      (base + 6).clamp(6.0, maxHeight),
      (base + 2).clamp(2.0, maxHeight),
    ];
  }
}
