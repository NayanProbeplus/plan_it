// lib/screens/settings/sunrise_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planit/theme/colors.dart';
import 'package:planit/widgets/gradient_text.dart';
import 'package:planit/widgets/sun_rise_controller.dart';

class SunriseWidget extends ConsumerStatefulWidget {
  const SunriseWidget({super.key});

  @override
  ConsumerState<SunriseWidget> createState() => _SunriseWidgetState();
}

class _SunriseWidgetState extends ConsumerState<SunriseWidget>
    with SingleTickerProviderStateMixin {
  // Only track vertical position (dy). X is locked to center each layout.
  late double sunDy;
  final double sunSize = 92;
  bool _moved = false;
  Offset _dragStartGlobal = Offset.zero;
  static const double _movementThreshold = 6.0; // px

  // clouds drifting
  late AnimationController _anim;
  late Animation<double> _cloudAnim;

  // sync flag to position orb initially according to saved theme
  bool _syncedWithTheme = false;

  @override
  void initState() {
    super.initState();
    // temporary initial value; will be clamped and possibly overwritten on first build
    sunDy = 120;
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _cloudAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _anim, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // Convert sun Y position into "day factor" 0..1 (1 = noon bright, 0 = midnight dark)
  double _dayFactor(double y, double height) {
    final clamped = y.clamp(0.0, height);
    // invert: top (0) => dayFactor=1, bottom(height) => 0
    final f = 1.0 - (clamped / height);
    return f.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;

        // compute center X and ensure sun stays horizontally centered
        final centerX = (maxW - sunSize) / 2;

        // --- mountains layout parameters (must match painter) ---
        final centerGap = sunSize * 0.8; // smaller gap than before
        centerGap.clamp(24.0, maxW * 0.28);
        // reduced horizontal offset so peaks are closer to center (was 0.18 * width)
        final horizontalOffset = maxW * 0.12;

        // mountain heights (same formula as painter)
        final baseY = maxH * 0.9;

        // clamp vertical position between top margin and allow going behind mountains:
        const topLimit = 12.0;

        // --- NEW: bottom padding to prevent going under bottom nav / controls ---
        // Adjust the constant (80.0) if your bottom nav is taller. This is
        // added to MediaQuery padding to account for devices with gesture bars.
        const double extraBottomPadding = 80.0;
        final double bottomSafe = MediaQuery.of(context).padding.bottom;
        final double bottomPadding = extraBottomPadding + bottomSafe;

        // allow sun to go slightly below mountain top, so it can appear behind them
        // bottomLimit aligns relative to baseY so orb can descend into the gap,
        // but never goes below (maxH - sunSize - bottomPadding).
        final candidateBottom = (baseY - sunSize * 0.12);
        final bottomLimit = min(candidateBottom, maxH - sunSize - bottomPadding)
            .clamp(topLimit, maxH - sunSize);

        // FIRST-TIME SYNC:
        // If we haven't synced yet, place orb according to saved theme:
        // - dark => put orb low (behind/near mountains)
        // - light => put orb higher (day)
        if (!_syncedWithTheme) {
          if (themeMode == ThemeMode.dark) {
            sunDy = bottomLimit; // place near mountains (moon)
          } else {
            // put it ~30% down from top for a nice day start
            sunDy = topLimit + (bottomLimit - topLimit) * 0.28;
          }
          _syncedWithTheme = true;
        }

        // ensure sunDy stays in allowed bounds on subsequent rebuilds
        sunDy = sunDy.clamp(topLimit, bottomLimit);

        final day = _dayFactor(sunDy + sunSize / 2, maxH);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Painted sky, clouds, stars, horizon, mountains etc.
              AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(maxW, maxH),
                    painter: _SkyPainter(
                      dayFactor: day,
                      cloudPhase: _cloudAnim.value,
                      showStars: day < 0.28,
                      centerGapWidth: centerGap,
                      horizontalOffset: horizontalOffset,
                    ),
                  );
                },
              ),

              // Draggable sun / moon overlay (locked horizontally at center)
              Positioned(
                left: centerX,
                top: sunDy,
                child: GestureDetector(
                  onPanStart: (details) {
                    _dragStartGlobal = details.globalPosition;
                    _moved = false;
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      // Only vertical movement allowed: update dy by delta dy
                      sunDy = (sunDy + details.delta.dy)
                          .clamp(topLimit, bottomLimit);
                    });

                    if ((details.globalPosition - _dragStartGlobal).distance >
                        _movementThreshold) {
                      _moved = true;
                    }
                  },
                  onPanEnd: (_) async {
                    // Set theme only if the user actually moved the orb.
                    if (_moved) {
                      const moonThreshold = 0.28;
                      if (day < moonThreshold) {
                        // user moved orb into night zone -> set dark & persist
                        await ref
                            .read(themeModeProvider.notifier)
                            .set(ThemeMode.dark);
                      } else {
                        // user moved orb into day zone -> set light & persist
                        await ref
                            .read(themeModeProvider.notifier)
                            .set(ThemeMode.light);
                      }
                      _moved = false;
                    }
                  },
                  child: _SunMoonWidget(
                    size: sunSize,
                    isMoon: day < 0.28,
                    dayFactor: day,
                  ),
                ),
              ),

              // instruction text
              Positioned(
                left: 12,
                right: 12,
                bottom: 20,
                child: Text(
                  'Drag the sun/moon vertically in the center to switch theme. Drag down to hide the sun behind the mountains.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    shadows: [
                      Shadow(
                          color: Colors.black.withOpacity(0.45),
                          offset: const Offset(0, 2),
                          blurRadius: 6)
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Draw sky, clouds, stars, mountains, ground. Mountains drawn with a center gap.
class _SkyPainter extends CustomPainter {
  final double dayFactor;
  final double cloudPhase;
  final bool showStars;
  final double centerGapWidth;
  final double horizontalOffset;

  _SkyPainter({
    required this.dayFactor,
    required this.cloudPhase,
    required this.showStars,
    required this.centerGapWidth,
    required this.horizontalOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintSky(canvas, size);
    _paintStars(canvas, size);
    _paintHorizon(canvas, size);
    _paintClouds(canvas, size);
    _paintMountains(canvas, size);
    _paintGround(canvas, size);
  }

  void _paintSky(Canvas canvas, Size size) {
    const topDay = Color(0xFF87CEEB);
    const bottomDay = Color(0xFFFCEFC7);
    const topNight = Color(0xFF021026);
    const bottomNight = Color(0xFF071226);

    Color lerpColor(Color a, Color b, double t) => Color.lerp(a, b, t) ?? a;

    final topColor = lerpColor(topNight, topDay, dayFactor);
    final bottomColor = lerpColor(bottomNight, bottomDay, dayFactor);

    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, bottomColor],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _paintStars(Canvas canvas, Size size) {
    if (!showStars) return;
    final starPaint = Paint();
    final rnd = Random(1234);
    const count = 70;
    for (int i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.6;
      final r = 0.6 + rnd.nextDouble() * 1.6;
      starPaint.color = Colors.white.withOpacity(0.6 + rnd.nextDouble() * 0.4);
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }
  }

  void _paintHorizon(Canvas canvas, Size size) {
    final horizonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.02 + dayFactor * 0.2),
          Colors.transparent
        ],
        radius: 0.6,
      ).createShader(Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.6),
        width: size.width * 0.8,
        height: size.height * 0.5,
      ));
    canvas.drawRect(Offset.zero & size, horizonPaint);
  }

  void _paintClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.85 * (0.6 + dayFactor * 0.4));

    final baseY = size.height * 0.18;
    const cloudCount = 3;
    for (int i = 0; i < cloudCount; i++) {
      final scale = 0.6 + i * 0.25;
      final width = size.width * (0.35 * scale);
      final xBase = ((i * 0.4 + cloudPhase * (0.6 + i * 0.2)) % 1.0) *
              (size.width + 200) -
          100;
      final y = baseY + i * 36.0;
      _drawCloud(
          canvas, Offset(xBase - width * 0.15, y), Size(width, 48), cloudPaint,
          opacity: 1.0 - (i * 0.12));
    }
  }

  void _drawCloud(Canvas canvas, Offset pos, Size sz, Paint paint,
      {double opacity = 1.0}) {
    final p = paint
      ..color = paint.color.withOpacity((paint.color.opacity) * opacity);
    final cx = pos.dx + sz.width * 0.5;
    final cy = pos.dy + sz.height * 0.5;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx - sz.width * 0.25, cy),
            width: sz.width * 0.6,
            height: sz.height * 0.9),
        p);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + sz.width * 0.0, cy - sz.height * 0.12),
            width: sz.width * 0.8,
            height: sz.height * 1.0),
        p);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + sz.width * 0.28, cy + sz.height * 0.08),
            width: sz.width * 0.55,
            height: sz.height * 0.85),
        p);

    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
        Rect.fromLTWH(pos.dx + sz.width * 0.05, pos.dy + sz.height * 0.45,
            sz.width * 0.9, sz.height * 0.28),
        shadow);
  }

  // Draw two mountains with a center gap (centerGapWidth) so the sun rises between them.
  void _paintMountains(Canvas canvas, Size size) {
    final gap = centerGapWidth.clamp(24.0, size.width * 0.28);
    final centerX = size.width / 2;
    // use provided reduced horizontalOffset so peaks are closer to center
    final leftPeakX = centerX - gap / 2 - horizontalOffset;
    final rightPeakX = centerX + gap / 2 + horizontalOffset;

    // heights
    final leftHeight = size.height * 0.32;
    final rightHeight = size.height * 0.38;

    // base Y (ground level)
    final baseY = size.height * 0.9;

    // mountain color changes slightly with dayFactor
    final dayTint = Color.lerp(
            const Color(0xFF0B3A2E), const Color(0xFF704214), dayFactor) ??
        const Color(0xFF2C3E50);

    final leftPaint = Paint()..color = dayTint.withOpacity(1.0);
    final rightPaint = Paint()..color = dayTint.withOpacity(0.95);

    // left mountain path (triangle-ish)
    final leftPath = Path();
    leftPath.moveTo(leftPeakX, baseY - leftHeight); // peak
    leftPath.lineTo(leftPeakX - (size.width * 0.28), baseY + 12); // left bottom
    leftPath.lineTo(centerX - gap / 2, baseY + 12); // inner bottom near gap
    leftPath.close();
    canvas.drawPath(leftPath, leftPaint);

    // right mountain path
    final rightPath = Path();
    rightPath.moveTo(rightPeakX, baseY - rightHeight); // peak
    rightPath.lineTo(
        rightPeakX + (size.width * 0.28), baseY + 12); // right bottom
    rightPath.lineTo(centerX + gap / 2, baseY + 12); // inner bottom near gap
    rightPath.close();
    canvas.drawPath(rightPath, rightPaint);

    // subtle highlights (lighter overlay) on mountains to add depth
    final highlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.02 + dayFactor * 0.08),
          Colors.transparent
        ],
      ).createShader(Rect.fromLTWH(
          0, baseY - size.height * 0.5, size.width, size.height * 0.5));

    canvas.drawPath(leftPath, highlight);
    canvas.drawPath(rightPath, highlight);

    // draw a small ridge/junction line to make the meeting visible
    final junctionPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final junctionLeft = Offset(centerX - gap / 2, baseY + 8);
    final junctionRight = Offset(centerX + gap / 2, baseY + 8);
    canvas.drawLine(junctionLeft, junctionRight, junctionPaint);
  }

  void _paintGround(Canvas canvas, Size size) {
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.08),
        ],
      ).createShader(
          Rect.fromLTRB(0, size.height * 0.8, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2),
        groundPaint);
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) {
    return old.dayFactor != dayFactor ||
        old.cloudPhase != cloudPhase ||
        old.showStars != showStars ||
        old.centerGapWidth != centerGapWidth ||
        old.horizontalOffset != horizontalOffset;
  }
}

/// Simple sun/moon orb widget (vector) with subtle shading.
/// `isMoon` switches visual style.
class _SunMoonWidget extends StatelessWidget {
  final double size;
  final bool isMoon;
  final double dayFactor;

  const _SunMoonWidget({
    required this.size,
    required this.isMoon,
    required this.dayFactor,
  });

  @override
  Widget build(BuildContext context) {
    final sunColor =
        Color.lerp(Colors.white, Colors.orange.shade400, dayFactor)!;
    final coolMoon = Colors.grey.shade200;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OrbPainter(
          color: isMoon ? coolMoon : sunColor,
          glow: isMoon ? 0.06 : 0.18 * dayFactor + 0.02,
          isMoon: isMoon,
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final Color color;
  final double glow;
  final bool isMoon;

  _OrbPainter({
    required this.color,
    required this.glow,
    required this.isMoon,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(glow), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.8));

    canvas.drawCircle(center, size.width * 0.9, glowPaint);

    // main disc
    final discPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.2),
        colors: [
          color,
          color.withOpacity(0.85),
          color.withOpacity(0.65),
        ],
      ).createShader(
          Rect.fromCircle(center: center, radius: size.width * 0.45));

    canvas.drawCircle(center, size.width * 0.45, discPaint);

    if (isMoon) {
      final clip = Path()
        ..addOval(Rect.fromCircle(
            center: center.translate(size.width * 0.12, -size.height * 0.05),
            radius: size.width * 0.38));
      final moon = Path()
        ..addOval(Rect.fromCircle(center: center, radius: size.width * 0.45));
      final crescent = Path.combine(PathOperation.difference, moon, clip);
      final moonPaint = Paint()..color = Colors.white.withOpacity(0.92);
      canvas.drawPath(crescent, moonPaint);
    }

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(isMoon ? 0.08 : 0.12);
    canvas.drawCircle(center, size.width * 0.45, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) {
    return old.color != color || old.glow != glow || old.isMoon != isMoon;
  }
}
