// lib/widgets/glass_button.dart
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:planit/theme/colors.dart';

/// Reusable glass button — can be used statically or with splash-style entrance.
/// If [visible] is non-null, the button will animate slide+fade based on its value.
/// If [visible] is null, the button renders statically (no entrance animation).
class GlassButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final bool showIcon;

  /// If null => static. If true/false => animate in/out.
  final bool? visible;

  /// Optional size overrides (keeps original sizing logic as default)
  final double? width;
  final double? height;

  /// Optional customizations
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassButton({
    super.key,
    this.onTap,
    this.title = 'Get Started',
    this.showIcon = true,
    this.visible, // if provided, triggers AnimatedSlide+Opacity
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive sizing identical to your original design
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;

    final double buttonHeight =
        (height ?? (screenWidth * 0.14)).clamp(56.0, 82.0);
    final double adjustedHeight =
        screenHeight < 600 ? math.max(52.0, buttonHeight * 0.9) : buttonHeight;
    final double buttonWidth = width ?? screenWidth * 0.7;

    // the core button widget (no entrance animation)
    Widget coreButton() {
      return Center(
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: buttonWidth,
              height: adjustedHeight,
              padding: padding ?? EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15), // your original fill
                borderRadius: borderRadius ?? BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: AppColors.accentPurple.withOpacity(0.2),
                  width: 1.0,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: borderRadius ?? BorderRadius.circular(20),
                  splashColor: AppColors.textPrimary.withOpacity(0.08),
                  highlightColor: AppColors.textPrimary.withOpacity(0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showIcon)
                        Container(
                          width: adjustedHeight * 0.7,
                          height: adjustedHeight * 0.7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentPurple.withOpacity(0.95),
                                AppColors.accentPink.withOpacity(0.95),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentPink.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: AppColors.charcoal,
                            size: math.max(18, adjustedHeight * 0.35),
                          ),
                        ),
                      if (showIcon) const SizedBox(width: 14),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: math.max(15, adjustedHeight * 0.28),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // If visible==null -> return static core button
    if (visible == null) return coreButton();

    // If visible is provided, wrap with the same slide+fade entrance you had
    final slideOffset = visible! ? Offset.zero : const Offset(0, 0.08);
    final opacity = visible! ? 1.0 : 0.0;

    // Also keep the bottom SafeArea/padding handling for screens like splash.
    // If you want the animated variant but without SafeArea, pass visible and
    // place the widget where you want (no enforced bottom padding).
    final bottomInset = mq.viewPadding.bottom;
    final double bottomPadding = bottomInset + 16.0;

    return SafeArea(
      bottom: true,
      child: AnimatedSlide(
        offset: slideOffset,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOut,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: coreButton(),
          ),
        ),
      ),
    );
  }
}
