// lib/widgets/slide_to_confirm_button.dart
import 'dart:ui';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:planit/theme/colors.dart';

/// onConfirmed should return `bool` or `Future<bool>`:
/// - true  = success (keep confirmed) unless resetOnSuccess == true
/// - false = failure (reset slider to left)
typedef ConfirmCallback = FutureOr<bool> Function();

class SlideToConfirmButton extends StatefulWidget {
  final bool visible;
  final String title;
  final ConfirmCallback? onConfirmed;
  final double? width;
  final double? height;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;

  /// If true, the slider will animate back to the start *after* a successful
  /// `onConfirmed()` (when it returns true). Default is false (keep confirmed).
  final bool resetOnSuccess;

  const SlideToConfirmButton({
    super.key,
    required this.visible,
    this.title = 'Get Started',
    this.onConfirmed,
    this.width,
    this.height,
    this.showIcon = true,
    this.padding,
    this.resetOnSuccess = false,
  });

  @override
  State<SlideToConfirmButton> createState() => _SlideToConfirmButtonState();
}

class _SlideToConfirmButtonState extends State<SlideToConfirmButton>
    with SingleTickerProviderStateMixin {
  // drag state
  double _thumbX = 0;
  bool _confirmed = false;
  bool _busy = false;
  late double _trackWidth;
  late double _thumbSize;
  late double _hitWidth;
  late AnimationController _snapCtrl;
  late Animation<double> _snapAnim;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _snapAnim = CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  void _animateThumbTo(double from, double to, {VoidCallback? onComplete}) {
    _snapCtrl.stop();
    _snapCtrl.reset();

    late final Animation<double> anim;
    void listener() {
      if (mounted) {
        setState(() {
          _thumbX = anim.value;
        });
      }
    }

    anim = Tween<double>(begin: from, end: to).animate(_snapAnim);
    anim.addListener(listener);

    _snapCtrl.forward().whenComplete(() {
      anim.removeListener(listener);
      if (onComplete != null && mounted) onComplete();
    });
  }

  void _onPanStart(DragStartDetails d) {
    if (_confirmed || _busy) return;
    _snapCtrl.stop();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_confirmed || _busy) return;
    setState(() {
      _thumbX = (_thumbX + d.delta.dx).clamp(0.0, _trackWidth - _thumbSize);
    });
  }

  // When pan ends: animate to end, call onConfirmed, then either keep or reset.
  void _onPanEnd(DragEndDetails d) {
    if (_confirmed || _busy) return;
    final threshold = (_trackWidth - _thumbSize) * 0.66;
    final current = _thumbX;
    if (current >= threshold) {
      final from = _thumbX;
      final to = _trackWidth - _thumbSize;

      // Animate to right edge for feedback
      _animateThumbTo(from, to, onComplete: () async {
        if (!mounted) return;
        setState(() => _busy = true);

        bool keep = true;
        try {
          if (widget.onConfirmed != null) {
            final res = widget.onConfirmed!();
            if (res is Future<bool>) {
              keep = await res;
            } else {
              keep = res;
            }
          } else {
            keep = true;
          }
        } catch (_) {
          keep = false;
        }

        if (!mounted) return;

        if (keep) {
          // success — either keep at end or reset to start depending on flag
          if (widget.resetOnSuccess) {
            // animate back to start, clear busy/confirmed when done
            setState(() => _busy = false);
            _animateThumbTo(_trackWidth - _thumbSize, 0.0, onComplete: () {
              if (!mounted) return;
              setState(() {
                _confirmed = false;
                _thumbX = 0.0;
              });
            });
          } else {
            // keep the thumb at end and mark confirmed
            setState(() {
              _confirmed = true;
              _busy = false;
              _thumbX = _trackWidth - _thumbSize;
            });
          }
        } else {
          // failure — animate back to start and clear busy
          setState(() => _busy = false);
          _animateThumbTo(_thumbX, 0.0, onComplete: () {
            if (!mounted) return;
            setState(() {
              _confirmed = false;
              _thumbX = 0.0;
            });
          });
        }
      });
    } else {
      // not across threshold → revert to start
      final from = _thumbX;
      _animateThumbTo(from, 0.0, onComplete: () {
        if (!mounted) return;
        setState(() {
          _confirmed = false;
          _thumbX = 0.0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final bottomInset = mq.viewPadding.bottom;

    final double buttonHeight =
        (widget.height ?? (screenWidth * 0.14)).clamp(56.0, 82.0);
    final double adjustedHeight =
        screenHeight < 600 ? math.max(52.0, buttonHeight * 0.9) : buttonHeight;
    final double buttonWidth = widget.width ?? screenWidth * 0.7;
    final double bottomPadding = bottomInset + 16.0;

    _thumbSize = adjustedHeight * 0.7;
    _hitWidth = math.max(_thumbSize, 48.0);
    _trackWidth = buttonWidth - 16.0;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Widget core() {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              width: buttonWidth,
              height: adjustedHeight,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: AppColors.accentPurple.withOpacity(0.16),
                  width: 1.0,
                ),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Title (center)
                  Center(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: math.max(15, adjustedHeight * 0.28),
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? cs.onSurface
                                .withOpacity(0.95) // light text on dark glass
                            : cs.onSurface,
                      ),
                    ),
                  ),

                  // Draggable track area
                  Positioned(
                    left: 8,
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: LayoutBuilder(builder: (context, constraints) {
                      final trackW = constraints.maxWidth;
                      _thumbX = _thumbX.clamp(0.0, trackW - _thumbSize);
                      final hitLeft = (_thumbX - (_hitWidth - _thumbSize) / 2)
                          .clamp(0.0, trackW - _hitWidth);

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // progress fill
                          Positioned(
                            left: 0,
                            top: (adjustedHeight - _thumbSize) / 2,
                            child: Container(
                              width: _thumbX + _thumbSize / 2,
                              height: _thumbSize,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.03),
                                    AppColors.plannerEmeraldGreen
                                        .withOpacity(0.06),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.04)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 1.8, sigmaY: 1.8),
                                  child: Container(color: Colors.transparent),
                                ),
                              ),
                            ),
                          ),

                          // draggable hit area
                          Positioned(
                            left: hitLeft,
                            top: (adjustedHeight - _hitWidth) / 2,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanStart: _onPanStart,
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: _onPanEnd,
                              child: SizedBox(
                                width: _hitWidth,
                                height: _hitWidth,
                                child: Center(
                                  child: Container(
                                    width: _thumbSize,
                                    height: _thumbSize,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.accentPurple
                                              .withOpacity(0.96),
                                          AppColors.accentPink
                                              .withOpacity(0.96),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accentPink
                                              .withOpacity(0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: _busy
                                          ? SizedBox(
                                              width: _thumbSize * 0.46,
                                              height: _thumbSize * 0.46,
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                              ),
                                            )
                                          : Icon(
                                              Icons.arrow_forward,
                                              color: AppColors.charcoal,
                                              size: math.max(
                                                  18, _thumbSize * 0.45),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // entrance animation
    final slideOffset = widget.visible ? Offset.zero : const Offset(0, 0.08);
    final opacity = widget.visible ? 1.0 : 0.0;

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
            child: core(),
          ),
        ),
      ),
    );
  }
}
