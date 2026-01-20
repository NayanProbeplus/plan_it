// lib/screens/payments/payment_display_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:planit/models/payment_reminder.dart';
import 'package:planit/providers/payment_reminders_provider.dart';
import 'package:planit/theme/colors.dart';
import 'package:planit/services/isar_services.dart';
import 'package:planit/widgets/delete_dlgBox.dart';
import 'package:planit/widgets/staggered_fade_animation.dart';
import 'package:planit/widgets/glass_edittexts_textfields.dart';

class PaymentDisplayScreen extends ConsumerWidget {
  const PaymentDisplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final asyncReminders = ref.watch(remindersStreamProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅ theme aware
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ✅
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: cs.onSurface.withOpacity(0.7), // ✅
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Payment Reminders',
          style: TextStyle(
            color: cs.primary, // ✅
            fontWeight: FontWeight.w900,
            fontSize: 18,
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PaymentFilterRow(),
              const SizedBox(height: 16),
              Expanded(
                child: asyncReminders.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'No payment reminders',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            color: cs.onSurface.withOpacity(0.6), // ✅
                          ),
                        ),
                      );
                    }

                    const topInitialDelay = Duration(milliseconds: 0);
                    const delayBetween = Duration(milliseconds: 60);
                    const fadeDuration = Duration(milliseconds: 700);

                    final children = [
                      for (final r in list)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GlassInputWrapper(
                            height: 70,
                            child: _DismissibleReminderTile(reminder: r),
                          ),
                        ),
                    ];

                    return SingleChildScrollView(
                      child: StaggeredFade(
                        initialDelay: topInitialDelay,
                        delayBetween: delayBetween,
                        fadeDuration: fadeDuration,
                        curve: Curves.easeIn,
                        mainAxisSize: MainAxisSize.min,
                        children: children,
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- DISMISSIBLE TILE ----------------

class _DismissibleReminderTile extends ConsumerWidget {
  final PaymentReminder reminder;
  const _DismissibleReminderTile({required this.reminder});

  Future<void> _performDelete(WidgetRef ref) async {
    await IsarService.isar.writeTxn(
      () => IsarService.isar.paymentReminders.delete(reminder.id),
    );
    ref.refresh(remindersStreamProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await showConfirmDialog(
          context,
          title: 'Delete payment?',
          message: 'Are you sure you want to delete "${reminder.name}"?',
          icon: Icons.delete_rounded,
          iconColor: AppColors.gold,
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
        );

        if (confirmed == true) {
          await _performDelete(ref);
          return true;
        }
        return false;
      },
      background: const Padding(
        padding: EdgeInsets.only(right: 16),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.delete_rounded, color: Colors.red),
        ),
      ),
      child: _ReminderTileCore(reminder: reminder),
    );
  }
}

/// ---------------- TILE CORE ----------------

class _ReminderTileCore extends ConsumerStatefulWidget {
  final PaymentReminder reminder;
  const _ReminderTileCore({required this.reminder});

  @override
  ConsumerState<_ReminderTileCore> createState() => _ReminderTileCoreState();
}

class _ReminderTileCoreState extends ConsumerState<_ReminderTileCore> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.reminder.isPaid == true;
  }

  Future<void> _togglePaid() async {
    final newValue = !isChecked;
    setState(() => isChecked = newValue);

    try {
      await IsarService.isar.writeTxn(() async {
        widget.reminder.isPaid = newValue;
        await IsarService.isar.paymentReminders.put(widget.reminder);
      });
      ref.refresh(remindersStreamProvider);
    } catch (_) {
      setState(() => isChecked = !newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = widget.reminder;
    final due = DateFormat.yMMMd().format(r.dueDate);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onLongPress: () {},
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.plannerEmeraldGreen.withOpacity(0.12),
              child: const Icon(Icons.payment_rounded,
                  color: AppColors.plannerEmeraldGreen),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.paymentType,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface, // ✅
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${r.name} · ${r.paymentOption}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.6), // ✅
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${r.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.warmAccentPurple,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  due,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 10,
                    color: AppColors.plannerEmeraldGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _togglePaid,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isChecked
                      ? Colors.green.withOpacity(0.18)
                      : AppColors.gold.withOpacity(0.12),
                  border: Border.all(
                    color: isChecked ? Colors.green : AppColors.textMuted,
                    width: 1.3,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: isChecked ? Colors.green : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter row (unchanged)
class PaymentFilterRow extends ConsumerWidget {
  const PaymentFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(paymentFilterProvider);

    Widget chip(String label, String value, Color color) {
      final bool active = selected == value;

      return GestureDetector(
        onTap: () => ref.read(paymentFilterProvider.notifier).state = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? color.withOpacity(0.14)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: active ? color : Colors.white.withOpacity(0.05),
                width: 1.4),
          ),
          child: Row(
            children: [
              Icon(
                value == 'all'
                    ? Icons.apps_rounded
                    : value == 'paid'
                        ? Icons.verified_rounded
                        : Icons.pending_actions_rounded,
                size: 16,
                color: active ? color : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: active ? color : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        chip("All Payments", "all", AppColors.accentPurple),
        const SizedBox(width: 8),
        chip("Paid", "paid", Colors.green),
        const SizedBox(width: 8),
        chip("Pending", "pending", AppColors.warningOrange),
      ],
    );
  }
}
