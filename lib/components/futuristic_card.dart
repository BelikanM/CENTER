import 'package:flutter/material.dart';

class FuturisticCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final double borderRadius;
  final bool showBorder;
  final bool showShadow;

  const FuturisticCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.gradientColors,
    this.borderRadius = 20,
    this.showBorder = true,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF5F5F5),
        gradient: gradientColors != null
            ? LinearGradient(
                colors: gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
