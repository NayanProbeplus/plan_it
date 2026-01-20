// lib/screens/home/today_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:planit/providers/payment_reminders_provider.dart';
import 'package:planit/providers/task_provider.dart';
import 'package:planit/theme/colors.dart';
import 'package:planit/widgets/glass_edittexts_textfields.dart';
import 'package:planit/widgets/gradient_text.dart';
import 'package:planit/widgets/staggered_fade_animation.dart';

/// Filter for TodayOverview: 'all', 'tasks', 'payments', 'meetings', 'events'
final todayFilterProvider = StateProvider<String>((_) => 'all');

class TodayOverviewScreen extends ConsumerWidget {
  const TodayOverviewScreen({super.key});

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final dateLabel = DateFormat.yMMMMd().format(today);

    // Animation timing constants (passed down)
    const topInitialDelay = Duration(milliseconds: 0);
    const delayBetween = Duration(milliseconds: 60);
    const fadeDuration = Duration(milliseconds: 700);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GradientText(
                          'Today',
                          gradient: AppColors.vibrantGradientBg,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Quicksand',
                          ),
                        ),
                        const SizedBox(height: 4),
                        // KEEP AS-IS: gradient date label + accent
                        GradientText(
                          dateLabel,
                          gradient: AppColors.darkAccentGradient,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Quicksand',
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Summary chips row — a ConsumerWidget below will watch filter + counts
                  const _TodaySummaryRow(),

                  const SizedBox(height: 18),

                  // Tiles section — watches DB + filter and is keyed for animation restart
                  _TodayTiles(
                    isSameDay: _isSameDay,
                    today: today,
                    topInitialDelay: topInitialDelay,
                    delayBetween: delayBetween,
                    fadeDuration: fadeDuration,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple model for rows
class _TodayItem {
  final String title;
  final String timeLabel;
  final IconData icon;
  final Color color;
  final bool? isPaid; // reused to indicate completed for tasks/payments

  _TodayItem({
    required this.title,
    required this.timeLabel,
    required this.icon,
    required this.color,
    this.isPaid,
  });
}

/// Summary row (chips-style) as a ConsumerWidget so only it rebuilds when needed.
class _TodaySummaryRow extends ConsumerWidget {
  const _TodaySummaryRow({super.key});

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(todayFilterProvider);

    // watch streams here only for counts (small widget)
    final asyncReminders = ref.watch(remindersStreamProvider);
    final asyncTasks = ref.watch(tasksStreamProvider);

    final today = DateTime.now();

    // compute counts with maybeWhen to avoid build-time side-effects
    final int tasksCount = asyncTasks.maybeWhen(
      data: (list) =>
          list.where((t) => _isSameDay(t.dueDate, today)).toList().length,
      orElse: () => 0,
    );

    // For meetings we currently don't have provider; set 0 or compute if you add one
    const int meetingsCount = 0;

    final int paymentsCount = asyncReminders.maybeWhen(
      data: (list) =>
          list.where((r) => _isSameDay(r.dueDate, today)).toList().length,
      orElse: () => 0,
    );

    // theme-aware color derivations
    final colorScheme = Theme.of(context).colorScheme;
    final onBg = colorScheme.onSurface;
    final onSurface = colorScheme.onSurface;
    onSurface.withOpacity(0.68);

    Widget chip(String label, String key, IconData icon, Color color) {
      final active = selected == key;
      final cs = Theme.of(context).colorScheme;

      const Color borderColor = AppColors.textMuted;

      final muted = cs.onSurface.withOpacity(0.6);

      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (ref.read(todayFilterProvider) == key) {
              ref.read(todayFilterProvider.notifier).state = 'all';
            } else {
              ref.read(todayFilterProvider.notifier).state = key;
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1.2, color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: active ? color : muted),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                      color: active ? color : cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('$tasksCount tasks', 'tasks', Icons.checklist_rounded,
            AppColors.successGreen),
        const SizedBox(width: 8),
        chip('$meetingsCount meetings', 'meetings', Icons.schedule_rounded,
            AppColors.darkAccentBlue),
        const SizedBox(width: 8),
        chip('$paymentsCount payments', 'payments', Icons.payments_rounded,
            AppColors.warningOrange),
      ],
    );
  }
}

/// Tiles widget — watches DB streams and selected filter + restarts the stagger animation
/// when filter changes (via ValueKey).
class _TodayTiles extends ConsumerWidget {
  final bool Function(DateTime a, DateTime b) isSameDay;
  final DateTime today;
  final Duration topInitialDelay;
  final Duration delayBetween;
  final Duration fadeDuration;

  const _TodayTiles({
    required this.isSameDay,
    required this.today,
    required this.topInitialDelay,
    required this.delayBetween,
    required this.fadeDuration,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(todayFilterProvider);
    final asyncReminders = ref.watch(remindersStreamProvider);
    final asyncTasks = ref.watch(tasksStreamProvider);

    // Use nested when() to wait for both streams (common pattern used earlier).
    return asyncReminders.when(
      data: (allReminders) {
        return asyncTasks.when(
          data: (allTasks) {
            // Meetings — static for now (replace with a provider if available)
            final meetings = <_TodayItem>[
              _TodayItem(
                title: 'Client sync – Acme Corp',
                timeLabel: '10:30 AM · 45 mins',
                icon: Icons.video_call_rounded,
                color: AppColors.darkAccentBlue,
              ),
              _TodayItem(
                title: 'Sprint planning',
                timeLabel: '3:00 PM · 30 mins',
                icon: Icons.event_note_rounded,
                color: AppColors.mintCyan,
              ),
            ];

            // Payments due today from reminders
            final paymentsReminders =
                allReminders.where((r) => isSameDay(r.dueDate, today)).toList();
            final payments = paymentsReminders.map((reminder) {
              final amountLabel = '₹${reminder.amount.toStringAsFixed(0)}';
              final paidSuffix =
                  reminder.isPaid == true ? ' · paid' : ' · pending';
              final timeLabel = '$amountLabel · Due today$paidSuffix';
              return _TodayItem(
                title: reminder.paymentType.isNotEmpty
                    ? '${reminder.paymentType} — ${reminder.name}'
                    : reminder.name,
                timeLabel: timeLabel,
                icon: Icons.payments_rounded,
                color: AppColors.warningOrange,
                isPaid: reminder.isPaid == true,
              );
            }).toList();

            // Tasks due today from DB
            final tasksDueToday =
                allTasks.where((t) => isSameDay(t.dueDate, today)).map((t) {
              final timePart = DateFormat.jm().format(t.dueDate);
              final status =
                  t.isCompleted == true ? ' · completed' : ' · pending';
              final timeLabel = 'Due today · $timePart$status';
              return _TodayItem(
                title: t.name,
                timeLabel: timeLabel,
                icon: Icons.task_alt_rounded,
                color: AppColors.successGreen,
                isPaid: t.isCompleted == true,
              );
            }).toList();

            // events (static)
            final events = <_TodayItem>[
              _TodayItem(
                title: 'Rohan’s birthday 🎂',
                timeLabel: 'Don’t forget to wish!',
                icon: Icons.cake_rounded,
                color: AppColors.accentPink,
              ),
            ];

            final hasAny = tasksDueToday.isNotEmpty ||
                meetings.isNotEmpty ||
                payments.isNotEmpty ||
                events.isNotEmpty;

            // Build children that will be put into StaggeredFade
            final children = <Widget>[];

            // top spacing already handled in parent; here add sections conditionally
            if (!hasAny) {
              children.add(const _EmptyTodayCard());
            } else {
              if (selectedFilter == 'all' || selectedFilter == 'tasks') {
                children.add(_SectionBlock(
                  title: 'Tasks',
                  icon: Icons.check_circle_rounded,
                  iconColor: AppColors.successGreen,
                  items: tasksDueToday,
                ));
                children.add(const SizedBox(height: 14));
              }

              if (selectedFilter == 'all' || selectedFilter == 'meetings') {
                children.add(_SectionBlock(
                  title: 'Meetings',
                  icon: Icons.event_available_rounded,
                  iconColor: AppColors.darkAccentBlue,
                  items: meetings,
                ));
                children.add(const SizedBox(height: 14));
              }

              if (selectedFilter == 'all' || selectedFilter == 'payments') {
                children.add(_SectionBlock(
                  title: 'Payments',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.warningOrange,
                  items: payments,
                ));
                children.add(const SizedBox(height: 14));
              }

              if (selectedFilter == 'all' || selectedFilter == 'events') {
                children.add(_SectionBlock(
                  title: 'Events & birthdays',
                  icon: Icons.cake_rounded,
                  iconColor: AppColors.accentPink,
                  items: events,
                ));
              }
            }

            // return StaggeredFade keyed by selectedFilter so animation restarts when it changes
            return StaggeredFade(
              key: ValueKey(selectedFilter),
              initialDelay: topInitialDelay,
              delayBetween: delayBetween,
              fadeDuration: fadeDuration,
              curve: Curves.easeIn,
              mainAxisSize: MainAxisSize.min,
              children: children,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Error loading tasks: $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Error loading reminders: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<_TodayItem> items;

  const _SectionBlock({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = items.isNotEmpty;
    final onBg = Theme.of(context).colorScheme.onSurface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Quicksand',
                color: onBg,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!hasItems)
          Text(
            'Nothing planned here 🎉',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Quicksand',
              color: onSurface.withOpacity(0.82),
              height: 1.2,
            ),
          )
        else
          Column(
            children: items
                .map(
                  (it) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GlassInputWrapper(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(it.icon, size: 20, color: it.color),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    it.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Quicksand',
                                      color: onBg,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    it.timeLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Quicksand',
                                      color: onSurface.withOpacity(0.9),
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (it.isPaid ?? false)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.successGreen,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

// Shown if literally everything is empty
class _EmptyTodayCard extends StatelessWidget {
  const _EmptyTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final onBg = Theme.of(context).colorScheme.onSurface;
    return const GlassInputWrapper(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              Icons.celebration_rounded,
              color: AppColors.successGreen,
              size: 24,
            ),
            SizedBox(width: 12),
            // NOTE: can't use theme inside a const; we'll recreate non-const below.
            // Keeping const for structure; replace with a non-const widget below if needed.
          ],
        ),
      ),
    );
  }
}
