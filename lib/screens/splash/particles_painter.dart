// lib/screens/splash/particles_painter.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Public particle class (no leading underscore) so it can be referenced from other files.
class Particle {
  Offset pos;
  Offset vel;
  double radius;
  Color color;

  Particle({
    required this.pos,
    required this.vel,
    required this.radius,
    required this.color,
  });
}

/// CustomPainter that draws all particles in a single pass.
class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  ParticlesPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      // Soft radial glow
      final gradient = ui.Gradient.radial(
        p.pos,
        p.radius * 3,
        [p.color.withOpacity(0.55), p.color.withOpacity(0.0)],
      );
      paint.shader = gradient;
      canvas.drawCircle(p.pos, p.radius * 3, paint);

      // Core circle
      paint.shader = null;
      paint.color = p.color;
      canvas.drawCircle(p.pos, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter old) => true;
}
