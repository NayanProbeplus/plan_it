// lib/widgets/animated_grid_card.dart
import 'package:flutter/material.dart';

class AnimatedGridCard extends StatelessWidget {
  final AnimationController controller;
  final Interval interval;
  final Widget child;
  final Offset offsetDirection;

  const AnimatedGridCard({
    super.key,
    required this.controller,
    required this.interval,
    required this.child,
    this.offsetDirection = const Offset(0.0, 0.06),
  });

  @override
  Widget build(BuildContext context) {
    final slideAnim = CurvedAnimation(
      parent: controller,
      curve: Interval(interval.begin, interval.end, curve: Curves.easeOutCubic),
    );

    final opacityAnim = CurvedAnimation(
      parent: controller,
      curve: Interval((interval.begin + 0.01).clamp(0.0, 1.0), interval.end,
          curve: Curves.easeInOut),
    );

    final scaleAnim = CurvedAnimation(
      parent: controller,
      curve: Interval(interval.begin, interval.end, curve: Curves.easeOut),
    );

    final slideTween =
        Tween<Offset>(begin: offsetDirection * 0.6, end: Offset.zero);
    final scaleTween = Tween<double>(begin: 0.985, end: 1.0);
    final opacityTween = Tween<double>(begin: 0.0, end: 1.0);

    return FadeTransition(
      opacity: opacityTween.animate(opacityAnim),
      child: SlideTransition(
        position: slideTween.animate(slideAnim),
        child: ScaleTransition(
          scale: scaleTween.animate(scaleAnim),
          child: child,
        ),
      ),
    );
  }
}
