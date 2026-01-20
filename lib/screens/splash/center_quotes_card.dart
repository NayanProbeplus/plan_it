import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:planit/theme/colors.dart';

class CenterQuoteCard extends StatelessWidget {
  final Animation<Offset> position;
  final Animation<double> opacity;
  final String quote;
  final TextStyle textStyle;

  /// Card width (optional).
  final double width;

  const CenterQuoteCard({
    super.key,
    required this.position,
    required this.opacity,
    required this.quote,
    required this.textStyle,
    this.width = 340,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveStyle = textStyle.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return SizedBox(
      width: width,
      child: SlideTransition(
        position: position,
        child: FadeTransition(
          opacity: opacity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // subtle outer gradient layer
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.06),
                          Colors.white.withOpacity(0.02),
                        ],
                      ),
                    ),
                  ),
                ),

                // frosted background + inner content
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.06),
                          AppColors.plannerEmeraldGreen.withOpacity(0.02),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.02),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(-3, -3),
                        ),
                      ],
                      border: Border.all(
                          color: Colors.white.withOpacity(0.12), width: 1.0),
                    ),
                    child: Stack(
                      children: [
                        // glossy highlight
                        Positioned(
                          left: 0,
                          top: 0,
                          right: 0,
                          height: 40,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.14),
                                    Colors.white.withOpacity(0.02),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // quote text
                        Center(
                          child: Text(
                            quote,
                            style: effectiveStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // small accent dot (decorative)
                Positioned(
                  bottom: 12,
                  right: 14,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
