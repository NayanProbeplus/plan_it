// lib/screens/home/stats_main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planit/core/router.dart';
import 'package:planit/providers/payment_reminders_provider.dart';
import 'package:planit/providers/stats_card_provider.dart';
import 'package:planit/providers/task_provider.dart';
import 'package:planit/utils/utilities.dart';
import 'package:planit/widgets/animated_grid_cards.dart';
import 'package:planit/screens/stats/stats_card.dart';

class StatsCardsGrid extends ConsumerStatefulWidget {
  const StatsCardsGrid({super.key});

  @override
  ConsumerState<StatsCardsGrid> createState() => StatsCardsGridGridState();
}

class StatsCardsGridGridState extends ConsumerState<StatsCardsGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Interval _stageInterval(
    double stageStart,
    double stageEnd,
    int itemIndexInStage,
    int itemsInStage,
  ) {
    final stageLen = (stageEnd - stageStart);
    final microStep = (itemsInStage <= 1)
        ? (stageLen * 0.12)
        : (stageLen / (itemsInStage * 4.0));
    final start =
        (stageStart + itemIndexInStage * microStep).clamp(0.0, stageEnd);
    final end = stageEnd.clamp(0.0, 1.0);
    return Interval(start, end, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(homeCardsProvider);

    final asyncPendingTasks = ref.watch(pendingTasksCountProvider);
    final asyncTotalTasks = ref.watch(totalTasksCountProvider);

    final asyncPendingCount = ref.watch(pendingPaymentsCountProvider);
    final asyncTotalCount = ref.watch(totalPaymentsCountProvider);

    const int crossAxisCount = 2;
    const double spacing = 10.0;

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    const extraNavReserve = 20.0;

    final screenWidth = MediaQuery.of(context).size.width;
    const double outerHorizontalPadding = 16 * 2;
    final double gridWidth = screenWidth - outerHorizontalPadding;
    final double cellWidth =
        (gridWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
    const double desiredCardHeight = 140.0;
    final double childAspectRatio = cellWidth / desiredCardHeight;

    final List<List<int>> stages = [
      [0],
      [2, 1],
      [4, 3],
      [6, 5],
      [7],
    ];

    const double perStageSeconds = 1.0;
    const double startGapSeconds = 0.2;
    final int stageCount = stages.length;
    final double totalSeconds =
        (stageCount - 1) * startGapSeconds + perStageSeconds;

    final List<double> stageStarts = List.generate(
      stageCount,
      (i) => (i * startGapSeconds) / totalSeconds,
    );

    final List<double> stageEnds = List.generate(
      stageCount,
      (i) => ((i * startGapSeconds) + perStageSeconds) / totalSeconds,
    );

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding:
              EdgeInsets.fromLTRB(16, 12, 16, bottomInset + extraNavReserve),
          child: GridView.builder(
            itemCount: cards.length,
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final model = cards[index];

              int stageIndex = stages.indexWhere((s) => s.contains(index));
              if (stageIndex < 0) stageIndex = 0;

              final interval = _stageInterval(
                stageStarts[stageIndex],
                stageEnds[stageIndex],
                stages[stageIndex].indexOf(index),
                stages[stageIndex].length,
              );

              String subtitleForDisplay = model.subtitle;
              double? progressForCard;

              if (model.title == 'Tasks') {
                subtitleForDisplay = asyncPendingTasks.when(
                  data: (count) => '$count Open',
                  loading: () => model.subtitle,
                  error: (_, __) => model.subtitle,
                );

                progressForCard = asyncPendingTasks.when(
                  data: (pending) => asyncTotalTasks.when(
                    data: (total) =>
                        total == 0 ? 0.0 : (pending / total).clamp(0.0, 1.0),
                    loading: () => 0.0,
                    error: (_, __) => 0.0,
                  ),
                  loading: () => 0.0,
                  error: (_, __) => 0.0,
                );
              }

              if (model.title == 'Payments') {
                subtitleForDisplay = asyncPendingCount.when(
                  data: (count) => '$count pending',
                  loading: () => model.subtitle,
                  error: (_, __) => model.subtitle,
                );

                progressForCard = asyncPendingCount.when(
                  data: (pending) => asyncTotalCount.when(
                    data: (total) =>
                        total == 0 ? 0.0 : (pending / total).clamp(0.0, 1.0),
                    loading: () => 0.0,
                    error: (_, __) => 0.0,
                  ),
                  loading: () => 0.0,
                  error: (_, __) => 0.0,
                );
              }

              final displayModel = StatsCardModel(
                title: model.title,
                subtitle: subtitleForDisplay,
                icon: model.icon,
              );

              return AnimatedGridCard(
                controller: _ctrl,
                interval: interval,
                offsetDirection: Offset.zero,
                child: HomeCard.small(
                  model: displayModel,
                  progress: progressForCard,
                  onTap: () {
                    if (model.title == 'Payments') {
                      context.push(Routes.paymentDisplay);
                    } else if (model.title == 'Tasks') {
                      context.push(Routes.taskDisplay);
                    } else {
                      AppToast.show("Tapped on ${model.title}");
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
