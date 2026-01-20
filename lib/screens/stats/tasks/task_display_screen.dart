// lib/screens/create/tasks/tasks_display_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:planit/models/task_model.dart';
import 'package:planit/providers/task_provider.dart';
import 'package:planit/theme/colors.dart';
import 'package:planit/services/isar_services.dart';
import 'package:planit/widgets/delete_dlgBox.dart';
import 'package:planit/widgets/staggered_fade_animation.dart';
import 'package:planit/widgets/glass_edittexts_textfields.dart';

final tasksFilterProvider = StateProvider<String>((_) => 'all');

class TaskDisplayScreen extends ConsumerWidget {
  const TaskDisplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final asyncTasks = ref.watch(tasksStreamProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: cs.onSurface.withOpacity(0.7),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tasks',
          style: TextStyle(
            color: cs.primary,
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
            children: [
              const SizedBox(height: 4),
              const _TaskFilterRow(),
              const SizedBox(height: 12),
              Expanded(
                child: asyncTasks.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'No tasks',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                      );
                    }

                    final filter = ref.watch(tasksFilterProvider);
                    var filtered = list;

                    if (filter == 'completed') {
                      filtered = list.where((t) => t.isCompleted).toList();
                    } else if (filter == 'pending') {
                      filtered = list.where((t) => !t.isCompleted).toList();
                    }

                    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));

                    return SingleChildScrollView(
                      child: StaggeredFade(
                        initialDelay: Duration.zero,
                        delayBetween: const Duration(milliseconds: 60),
                        fadeDuration: const Duration(milliseconds: 700),
                        curve: Curves.easeIn,
                        children: [
                          for (final t in filtered)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: GlassInputWrapper(
                                height: 70,
                                child: _DismissibleTaskTile(task: t),
                              ),
                            ),
                        ],
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

/// ---------------- FILTER ROW ----------------

class _TaskFilterRow extends ConsumerWidget {
  const _TaskFilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selected = ref.watch(tasksFilterProvider);

    Widget chip(String label, String value, Color accent) {
      final active = selected == value;

      return GestureDetector(
        onTap: () => ref.read(tasksFilterProvider.notifier).state = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? accent.withOpacity(0.14)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? accent : cs.onSurface.withOpacity(0.1),
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Icon(
                value == 'all'
                    ? Icons.apps_rounded
                    : value == 'completed'
                        ? Icons.verified_rounded
                        : Icons.pending_actions_rounded,
                size: 16,
                color: active ? accent : cs.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: active ? accent : cs.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: chip('All Tasks', 'all', AppColors.accentPurple)),
        const SizedBox(width: 6),
        Expanded(child: chip('Completed', 'completed', Colors.green)),
        const SizedBox(width: 6),
        Expanded(child: chip('Open', 'pending', AppColors.warningOrange)),
      ],
    );
  }
}

/// ---------------- DISMISSIBLE TILE ----------------

class _DismissibleTaskTile extends ConsumerWidget {
  final Task task;
  const _DismissibleTaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final ok = await showConfirmDialog(
          context,
          title: 'Delete task?',
          message: 'Delete "${task.name}"?',
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
          icon: Icons.delete_rounded,
          iconColor: AppColors.gold,
        );
        if (ok == true) {
          await IsarService.isar
              .writeTxn(() => IsarService.isar.tasks.delete(task.id));
          ref.refresh(tasksStreamProvider);
          return true;
        }
        return false;
      },
      background: const Padding(
        padding: EdgeInsets.only(right: 16),
        child: Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete_rounded, color: Colors.red)),
      ),
      child: _TaskTileCore(task: task),
    );
  }
}

/// ---------------- TILE CORE (NO BOX HERE) ----------------

class _TaskTileCore extends ConsumerStatefulWidget {
  final Task task;
  const _TaskTileCore({required this.task});

  @override
  ConsumerState<_TaskTileCore> createState() => _TaskTileCoreState();
}

class _TaskTileCoreState extends ConsumerState<_TaskTileCore> {
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.task.isCompleted;
  }

  Future<void> _toggleComplete() async {
    final next = !isCompleted;
    setState(() => isCompleted = next);
    await IsarService.isar.writeTxn(() async {
      widget.task.isCompleted = next;
      await IsarService.isar.tasks.put(widget.task);
    });
    ref.refresh(tasksStreamProvider);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = widget.task;
    final dueText = DateFormat.yMMMd().format(t.dueDate);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity, // 🔑 FIXES WIDTH ISSUE
        height: 96,
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.plannerEmeraldGreen.withOpacity(0.12),
              child: const Icon(Icons.task_alt_rounded,
                  color: AppColors.plannerEmeraldGreen),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Due · $dueText',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _toggleComplete,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green.withOpacity(0.18)
                      : AppColors.gold.withOpacity(0.12),
                  border: Border.all(
                    color: isCompleted ? Colors.green : AppColors.textMuted,
                    width: 1.3,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: isCompleted ? Colors.green : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
