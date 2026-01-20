// lib/widgets/gradient_switch.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:planit/theme/colors.dart';
import 'package:planit/theme/glass.dart';

class GradientSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Duration duration;

  const GradientSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 56,
    this.height = 32,
    this.duration = const Duration(milliseconds: 220),
  });

  @override
  State<GradientSwitch> createState() => _GradientSwitchState();
}

class _GradientSwitchState extends State<GradientSwitch>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final double thumbSize = widget.height - 6;
    final double trackRadius = widget.height / 2;

    return Semantics(
      toggled: widget.value,
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
        child: AnimatedContainer(
          duration: widget.duration,
          width: widget.width,
          height: widget.height,
          curve: Curves.easeInOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(trackRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: Glass.blurSigma, sigmaY: Glass.blurSigma),
              child: Container(
                // Glass track (constant)
                decoration: BoxDecoration(
                  gradient: Glass.defaultFillGradient,
                  borderRadius: BorderRadius.circular(trackRadius),
                  border: Border.all(
                      color: Glass.borderColor(), width: Glass.borderWidth),
                  boxShadow: [
                    BoxShadow(
                      color: Glass.shadowColor,
                      blurRadius: Glass.shadowBlur,
                      offset: const Offset(0, Glass.shadowOffsetY),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // subtle inner highlight (always there)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(trackRadius),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.02),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Thumb (animated left <-> right)
                    AnimatedAlign(
                      duration: widget.duration,
                      curve: Curves.easeInOut,
                      alignment: widget.value
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          width: thumbSize,
                          height: thumbSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: widget.value
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.accentPurple,
                                      AppColors.accentPink,
                                    ],
                                  )
                                : null,
                            color: widget.value ? null : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              color: widget.value
                                  ? Colors.white.withOpacity(0.06)
                                  : AppColors.backgroundLight.withOpacity(0.06),
                              width: 0.6,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              widget.value
                                  ? Icons.notifications_on_rounded
                                  : Icons.notifications_off_rounded,
                              size: thumbSize * 0.56,
                              color: widget.value
                                  ? AppColors.charcoal
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
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
}
