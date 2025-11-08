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
        color: backgroundColor ?? Colors.white,
        gradient: gradientColors != null
            ? LinearGradient(
                colors: gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? const Border(
                top: BorderSide(color: Color(0xFF00FF88), width: 2),
                left: BorderSide(color: Color(0xFF00FF88), width: 2),
                right: BorderSide(color: Color(0xFF00FF88), width: 2),
                bottom: BorderSide(color: Color(0xFF00FF88), width: 2),
              )
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF00FF88).withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 25,
                  offset: const Offset(0, 15),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
