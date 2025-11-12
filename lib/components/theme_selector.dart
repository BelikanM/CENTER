import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

/// Widget de sélection de thème avec aperçu visuel
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final currentTheme = themeProvider.currentTheme;

        return Container(
          padding: const EdgeInsets.all(16), // Réduit de 20 à 16
          decoration: BoxDecoration(
            color: currentTheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: currentTheme.primary.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10), // Réduit de 12 à 10
                    decoration: BoxDecoration(
                      gradient: currentTheme.gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.palette_rounded,
                      color: currentTheme.isDark ? Colors.white : Colors.black,
                      size: 22, // Réduit de 24 à 22
                    ),
                  ),
                  const SizedBox(width: 12), // Réduit de 16 à 12
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thème de l\'application',
                          style: TextStyle(
                            fontSize: 17, // Réduit de 18 à 17
                            fontWeight: FontWeight.w700,
                            color: currentTheme.text,
                          ),
                        ),
                        Text(
                          currentTheme.name,
                          style: TextStyle(
                            fontSize: 13, // Réduit de 14 à 13
                            color: currentTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Toggle Dark Mode
                  IconButton(
                    onPressed: () => themeProvider.toggleDarkMode(),
                    icon: Icon(
                      currentTheme.isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: currentTheme.primary,
                    ),
                    tooltip: currentTheme.isDark
                        ? 'Passer en mode clair'
                        : 'Passer en mode sombre',
                  ),
                ],
              ),

              const SizedBox(height: 12), // Réduit de 20 à 12

              // Grille de thèmes
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10, // Réduit de 12 à 10
                  mainAxisSpacing: 10, // Réduit de 12 à 10
                  childAspectRatio: 0.85, // Augmenté de 0.8 à 0.85 pour moins de hauteur
                ),
                itemCount: AppTheme.allThemes.length,
                itemBuilder: (context, index) {
                  final theme = AppTheme.allThemes[index];
                  final isSelected = theme.id == currentTheme.id;

                  return _ThemeCard(
                    theme: theme,
                    isSelected: isSelected,
                    onTap: () => themeProvider.setTheme(theme),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Carte individuelle de thème
class _ThemeCard extends StatelessWidget {
  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primary : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1,
          ),
          gradient: theme.gradient,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône emoji du thème
            Text(
              theme.icon,
              style: const TextStyle(fontSize: 24), // Réduit de 28 à 24
            ),
            const SizedBox(height: 6), // Réduit de 8 à 6
            
            // Nom du thème
            Text(
              theme.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10, // Réduit de 11 à 10
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: theme.isDark ? Colors.white : Colors.black,
              ),
            ),

            // Indicateur de sélection
            if (isSelected) ...[
              const SizedBox(height: 3), // Réduit de 4 à 3
              Icon(
                Icons.check_circle_rounded,
                color: theme.isDark ? Colors.white : Colors.black,
                size: 14, // Réduit de 16 à 14
              ),
            ],
          ],
        ),
      ),
    );
  }
}
