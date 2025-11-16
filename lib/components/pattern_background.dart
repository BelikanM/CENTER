import 'package:flutter/material.dart';
import '../utils/pattern_manager.dart';

/// Widget de fond avec pattern pour remplacer les espaces blancs
class PatternBackground extends StatelessWidget {
  final Widget child;
  final String? patternKey;
  final double opacity;
  final BoxFit fit;
  final Color? overlayColor;
  final double overlayOpacity;

  const PatternBackground({
    super.key,
    required this.child,
    this.patternKey,
    this.opacity = 0.15,
    this.fit = BoxFit.cover,
    this.overlayColor,
    this.overlayOpacity = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final patternManager = PatternManager();
    final patternPath = patternKey != null 
        ? patternManager.getPatternForComponent(patternKey!)
        : patternManager.getRandomPattern();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(patternPath),
          fit: fit,
          opacity: opacity,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: overlayColor != null
          ? Container(
              color: overlayColor!.withValues(alpha: overlayOpacity),
              child: child,
            )
          : child,
    );
  }
}

/// Widget de fond avec pattern et gradient
class PatternGradientBackground extends StatelessWidget {
  final Widget child;
  final String? patternKey;
  final double patternOpacity;
  final List<Color> gradientColors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const PatternGradientBackground({
    super.key,
    required this.child,
    this.patternKey,
    this.patternOpacity = 0.1,
    this.gradientColors = const [Colors.white, Color(0xFFF5F5F5)],
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    final patternManager = PatternManager();
    final patternPath = patternKey != null 
        ? patternManager.getPatternForComponent(patternKey!)
        : patternManager.getRandomPattern();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(patternPath),
          fit: BoxFit.cover,
          opacity: patternOpacity,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: gradientColors,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Widget de pattern subtil pour les cartes et containers
class SubtlePatternContainer extends StatelessWidget {
  final Widget child;
  final String? patternKey;
  final double patternOpacity;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const SubtlePatternContainer({
    super.key,
    required this.child,
    this.patternKey,
    this.patternOpacity = 0.05,
    this.backgroundColor = Colors.white,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final patternManager = PatternManager();
    final patternPath = patternKey != null 
        ? patternManager.getPatternForComponent(patternKey!)
        : patternManager.getRandomPattern();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        border: border,
        image: DecorationImage(
          image: AssetImage(patternPath),
          fit: BoxFit.cover,
          opacity: patternOpacity,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: child,
    );
  }
}

/// Pattern pour la barre de navigation
class NavBarPatternBackground extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final double patternOpacity;

  const NavBarPatternBackground({
    super.key,
    required this.child,
    this.baseColor = Colors.white,
    this.patternOpacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    final patternManager = PatternManager();
    final patternPath = patternManager.getPatternForComponent('navbar');

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        image: DecorationImage(
          image: AssetImage(patternPath),
          fit: BoxFit.cover,
          opacity: patternOpacity,
          repeat: ImageRepeat.repeat,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}
