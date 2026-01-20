// lib/widgets/home_card.dart
import 'package:flutter/material.dart';
import 'package:planit/providers/stats_card_provider.dart';
import 'package:planit/theme/glass.dart';
import 'package:planit/utils/utilities.dart';

class HomeCard extends StatefulWidget {
  final StatsCardModel model;
  final bool compact;

  /// progress should be in range [0.0, 1.0]. If null, a legacy heuristic is used.
  final double? progress;
  final VoidCallback? onTap;

  const HomeCard({
    super.key,
    required this.model,
    this.onTap,
    this.progress,
  }) : compact = false;

  const HomeCard.small({
    super.key,
    required this.model,
    this.onTap,
    this.progress,
  }) : compact = true;

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails d) => _anim.reverse();
  void _onTapUp(TapUpDetails d) => _anim.forward();
  void _onTapCancel() => _anim.forward();

  void _onTap() => widget.onTap?.call();

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ScaleTransition(
      scale: _anim,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availH = constraints.maxHeight;
            final bool cramped = availH < 96.0;

            final double cardPadding = cramped ? 8.0 : 12.0;
            final double iconSize = cramped ? 14.0 : 20.0;
            final double titleSize = cramped ? 13.0 : 16.0;
            final double subtitleSize = cramped ? 10.0 : 12.0;
            final double progressHeight = cramped ? 4.0 : 6.0;
            final double cornerRadius = cramped ? 12.0 : 14.0;
            final double smallGap = cramped ? 4.0 : 6.0;
            final double bottomGap = cramped ? 6.0 : 8.0;

            // === Progress handling ===
            double effectiveProgress;
            int percentDisplay;

            if (widget.progress != null) {
              effectiveProgress = widget.progress!.clamp(0.0, 1.0);
              percentDisplay = (effectiveProgress * 100).round();
            } else {
              effectiveProgress =
                  (0.36 + (model.title.length % 4) * 0.12).clamp(0.0, 1.0);
              percentDisplay = (20 + model.title.length * 3);
            }

            final onSurface = cs.onSurface;
            final subtitleColor = onSurface.withOpacity(0.78);
            final mutedColor = onSurface.withOpacity(0.66);
            final iconBg = cs.primary.withOpacity(0.10);
            final iconColor = cs.primary;
            final progressColor = cs.primary;
            final progressBg = cs.surface.withOpacity(0.08);

            return GlassContainer(
              borderRadius: BorderRadius.circular(cornerRadius),
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // icon + action
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(cardPadding - 4),
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          model.icon,
                          size: iconSize,
                          color: iconColor,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          AppToast.show("Action tapped on ${model.title}");
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          child: Icon(
                            Icons.more_horiz,
                            size: 18,
                            color: mutedColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: smallGap),

                  // Title + subtitle
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          model.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleMedium?.copyWith(
                                fontFamily: 'Quicksand',
                                fontSize: titleSize,
                                fontWeight: FontWeight.w800,
                                color: onSurface,
                                height: 1.2,
                              ) ??
                              TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: titleSize,
                                fontWeight: FontWeight.w800,
                                color: onSurface,
                                height: 1.2,
                              ),
                        ),
                        SizedBox(height: cramped ? 2 : 4),
                        Text(
                          model.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall?.copyWith(
                                fontFamily: 'Quicksand',
                                fontSize: subtitleSize,
                                color: subtitleColor,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ) ??
                              TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: subtitleSize,
                                color: subtitleColor,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: bottomGap),

                  // Progress row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: progressHeight,
                          decoration: BoxDecoration(
                            color: progressBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: effectiveProgress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: progressColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$percentDisplay%',
                        style: tt.bodySmall?.copyWith(
                              fontFamily: 'Quicksand',
                              fontSize: cramped ? 10 : 11,
                              fontWeight: FontWeight.w700,
                              color: subtitleColor,
                            ) ??
                            TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: cramped ? 10 : 11,
                              fontWeight: FontWeight.w700,
                              color: subtitleColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
