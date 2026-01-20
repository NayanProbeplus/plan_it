// lib/theme/glass.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:planit/theme/colors.dart';

class Glass {
  static const double blurSigma = 10.0;
  static const double fillOpacity = 0.15;
  static const double borderOpacity = 0.12;
  static const double borderWidth = 1.0;
  static const double shadowBlur = 18.0;
  static const double shadowOffsetY = 8.0;
  static final Color shadowColor = Colors.black.withOpacity(0.08);
  static const double radius = 20.0;

  // Accent gradient for small decorative elements
  static Gradient accentGradient({double a = 0.95}) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accentPurple.withOpacity(a),
          AppColors.accentPink.withOpacity(a),
        ],
      );

  // Main button border color (subtle)
  static Color borderColor() => Colors.white.withOpacity(borderOpacity);

  // Fill gradient used by many glass components
  static Gradient defaultFillGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(fillOpacity),
      AppColors.plannerEmeraldGreen.withOpacity(0.02),
    ],
  );
}

/// Small wrapper you can reuse everywhere to get the exact same glass look
class GlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(Glass.radius);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: Glass.blurSigma, sigmaY: Glass.blurSigma),
        child: Container(
          width: width,
          height: height,
          constraints: constraints,
          padding: padding,
          decoration: BoxDecoration(
            gradient: Glass.defaultFillGradient,
            borderRadius: br,
            boxShadow: [
              BoxShadow(
                color: Glass.shadowColor,
                blurRadius: Glass.shadowBlur,
                offset: const Offset(0, Glass.shadowOffsetY),
              ),
            ],
            border: Border.all(
                color: Glass.borderColor(), width: Glass.borderWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}
