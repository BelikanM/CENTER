import 'package:flutter/material.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;
  final int count;
  final bool showBadge;
  final Color badgeColor;
  final Color textColor;

  const NotificationBadge({
    super.key,
    required this.child,
    this.count = 0,
    this.showBadge = false,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.showBadge) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showBadge && !oldWidget.showBadge) {
      _controller.repeat(reverse: true);
    } else if (!widget.showBadge && oldWidget.showBadge) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.showBadge && widget.count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.badgeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.badgeColor.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        widget.count > 99 ? '99+' : widget.count.toString(),
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Widget pour l'effet de scintillement des bordures
class GlowingBorder extends StatefulWidget {
  final Widget child;
  final bool isGlowing;
  final Color glowColor;
  final double borderRadius;

  const GlowingBorder({
    super.key,
    required this.child,
    this.isGlowing = false,
    this.glowColor = const Color(0xFF00D4FF),
    this.borderRadius = 0,
  });

  @override
  State<GlowingBorder> createState() => _GlowingBorderState();
}

class _GlowingBorderState extends State<GlowingBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isGlowing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowingBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGlowing && !oldWidget.isGlowing) {
      _controller.repeat(reverse: true);
    } else if (!widget.isGlowing && oldWidget.isGlowing) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isGlowing) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: _animation.value * 0.6),
                blurRadius: 20 * _animation.value,
                spreadRadius: 5 * _animation.value,
              ),
              BoxShadow(
                color: widget.glowColor.withValues(alpha: _animation.value * 0.3),
                blurRadius: 40 * _animation.value,
                spreadRadius: 10 * _animation.value,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: widget.glowColor.withValues(alpha: _animation.value),
                width: 2,
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
