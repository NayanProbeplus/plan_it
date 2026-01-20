// lib/widgets/staggered_fade.dart
import 'package:flutter/material.dart';

/// StaggeredFade
/// - Accepts a list of [children] and fades them in one by one.
/// - [delayBetween] is the time between start of child i and i+1.
/// - [fadeDuration] is how long each child's fade-in lasts.
/// - [initialDelay] is an optional delay before the first child starts.
/// - [curve] controls the fade curve.
/// - [axis] and [mainAxisSize] let you tweak how children are laid out (defaults to Column).
///
/// New: also supports a slide + entrance-scale animation per child.
/// - [slideOffset] controls where each child begins (Offset(x,y)). Default = Offset(0, 0.06)
///   (i.e. slightly below its final position).
/// - [scaleBegin] controls the initial scale for the entrance pop. Default = 0.985.
class StaggeredFade extends StatefulWidget {
  final List<Widget> children;
  final Duration delayBetween;
  final Duration fadeDuration;
  final Duration initialDelay;
  final Curve curve;

  // Layout options (defaults make it behave like Column)
  final Axis axis;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  // New tuning options for slide + scale
  final Offset slideOffset;
  final double scaleBegin;
  final Curve slideCurve;
  final Curve scaleCurve;

  // Optional callback when full animation completes
  final VoidCallback? onCompleted;

  const StaggeredFade({
    super.key,
    required this.children,
    this.delayBetween = const Duration(milliseconds: 200),
    this.fadeDuration = const Duration(seconds: 1),
    this.initialDelay = Duration.zero,
    this.curve = Curves.easeIn,
    this.axis = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    // slide + scale defaults:
    this.slideOffset = const Offset(0, 0.06),
    this.scaleBegin = 0.985,
    this.slideCurve = Curves.easeOutCubic,
    this.scaleCurve = Curves.easeOut,
    this.onCompleted,
  });

  @override
  State<StaggeredFade> createState() => _StaggeredFadeState();
}

class _StaggeredFadeState extends State<StaggeredFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _anims;
  late final List<Animation<Offset>> _slideAnims;
  late final List<Animation<double>> _scaleAnims;

  @override
  void initState() {
    super.initState();

    final n = widget.children.length;
    // total length = initialDelay + delayBetween*(n-1) + fadeDuration
    final totalMs = widget.initialDelay.inMilliseconds +
        (widget.delayBetween.inMilliseconds * (n - 1)) +
        widget.fadeDuration.inMilliseconds;

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );

    _anims = List.generate(n, (i) {
      final childStartMs = widget.initialDelay.inMilliseconds +
          (i * widget.delayBetween.inMilliseconds);
      final childEndMs = childStartMs + widget.fadeDuration.inMilliseconds;

      final start = (childStartMs / totalMs).clamp(0.0, 1.0);
      final end = (childEndMs / totalMs).clamp(0.0, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _ctrl, curve: Interval(start, end, curve: widget.curve)),
      );
    });

    // slide animations (Offset -> Offset.zero) using slideCurve
    _slideAnims = List.generate(n, (i) {
      final childStartMs = widget.initialDelay.inMilliseconds +
          (i * widget.delayBetween.inMilliseconds);
      final childEndMs = childStartMs + widget.fadeDuration.inMilliseconds;

      final start = (childStartMs / totalMs).clamp(0.0, 1.0);
      final end = (childEndMs / totalMs).clamp(0.0, 1.0);

      return Tween<Offset>(begin: widget.slideOffset, end: Offset.zero).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: Interval(start, end, curve: widget.slideCurve)),
      );
    });

    // scale animations (scaleBegin -> 1.0) using scaleCurve
    _scaleAnims = List.generate(n, (i) {
      final childStartMs = widget.initialDelay.inMilliseconds +
          (i * widget.delayBetween.inMilliseconds);
      final childEndMs = childStartMs + widget.fadeDuration.inMilliseconds;

      final start = (childStartMs / totalMs).clamp(0.0, 1.0);
      final end = (childEndMs / totalMs).clamp(0.0, 1.0);

      return Tween<double>(begin: widget.scaleBegin, end: 1.0).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: Interval(start, end, curve: widget.scaleCurve)),
      );
    });

    _ctrl.forward().whenComplete(() {
      if (widget.onCompleted != null) widget.onCompleted!();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build either Column or Row depending on axis
    final children = List<Widget>.generate(widget.children.length, (i) {
      // Wrap order: Fade -> Slide -> Scale -> child
      // (scale is inside slide so scaling occurs in-place while slide moves)
      return FadeTransition(
        opacity: _anims[i],
        child: SlideTransition(
          position: _slideAnims[i],
          child: ScaleTransition(
            scale: _scaleAnims[i],
            child: widget.children[i],
          ),
        ),
      );
    });

    if (widget.axis == Axis.vertical) {
      return Column(
        mainAxisSize: widget.mainAxisSize,
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        children: children,
      );
    } else {
      return Row(
        mainAxisSize: widget.mainAxisSize,
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        children: children,
      );
    }
  }
}
