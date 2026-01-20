import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final ts = style ?? const TextStyle();
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: ts.copyWith(color: Colors.white),
      ),
    );
  }
}
