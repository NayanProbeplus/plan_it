// lib/screens/create/tasks/add_task_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planit/models/task_model.dart';
import 'package:planit/services/isar_services.dart';
import 'package:planit/theme/colors.dart';
import 'package:planit/utils/utilities.dart';
import 'package:planit/widgets/glass_edittexts_textfields.dart';
import 'package:planit/widgets/gradient_switch.dart';
import 'package:planit/widgets/gradient_text.dart';
import 'package:planit/widgets/slide_to_confirm_button.dart';
import 'package:planit/widgets/staggered_fade_animation.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _shouldRemind = false;

  final Duration topInitialDelay = const Duration(milliseconds: 0);
  final Duration delayBetween = const Duration(milliseconds: 30);
  final Duration fadeDuration = const Duration(milliseconds: 300);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<bool> _onAddTask() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppToast.show('Please fix the errors in the form');
      return false;
    }

    if (_selectedDate == null) {
      AppToast.show('Please select a due date');
      return false;
    }

    final task = Task.create(
      name: _nameController.text.trim(),
      dueDate: _selectedDate!,
      remind: _shouldRemind,
    );

    try {
      int savedId = -1;
      await IsarService.isar.writeTxn(() async {
        savedId = await IsarService.isar.tasks.put(task);
      });

      if (_shouldRemind) {
        scheduleOrShowReminderNotification(
          id: savedId,
          title: 'Task due',
          body:
              '${task.name} due on ${DateFormat.yMMMd().format(task.dueDate)}',
          dueDate: task.dueDate,
        );
      }

      AppToast.show('Task created. Check Overview for updates');

      setState(() {
        _nameController.clear();
        _selectedDate = null;
        _shouldRemind = false;
      });

      return true;
    } catch (e) {
      AppToast.show('Error saving task. Please try again.');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final dateText = _selectedDate == null
        ? 'Choose date'
        : DateFormat.yMMMd().format(_selectedDate!);

    final topChildren = <Widget>[
      const SizedBox(height: 4),

      GradientText(
        'Add a task',
        gradient: AppColors.vibrantGradientBg,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Quicksand',
        ),
      ),

      const SizedBox(height: 6),
      Text(
        'Quickly add a task to your day.',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'MomoSignature',
          color: cs.secondary,
        ),
      ),

      const SizedBox(height: 18),

      // ---------- Task name ----------
      Text(
        'Task name',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Quicksand',
          color: cs.onSurface.withOpacity(0.75),
        ),
      ),
      const SizedBox(height: 6),

      GlassInputWrapper(
        child: TextFormField(
          controller: _nameController,
          cursorColor: cs.primary,
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Finish report, Plan dinner',
            hintStyle: TextStyle(
              color: cs.onSurface.withOpacity(0.5),
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter a task name' : null,
        ),
      ),

      const SizedBox(height: 16),

      // ---------- Date ----------
      Text(
        'Date to complete',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Quicksand',
          color: cs.onSurface.withOpacity(0.75),
        ),
      ),
      const SizedBox(height: 6),

      GlassInputWrapper(
        child: InkWell(
          onTap: _pickDate,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  dateText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w700,
                    color: _selectedDate == null
                        ? cs.onSurface.withOpacity(0.5)
                        : cs.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: cs.onSurface.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 16),

      // ---------- Remind ----------
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remind me',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Quicksand',
                    color: cs.onSurface.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enable notification for this task',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Quicksand',
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          GradientSwitch(
            value: _shouldRemind,
            onChanged: (v) => setState(() => _shouldRemind = v),
          ),
        ],
      ),

      const SizedBox(height: 20),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Form(
                  key: _formKey,
                  child: StaggeredFade(
                    initialDelay: topInitialDelay,
                    delayBetween: delayBetween,
                    fadeDuration: fadeDuration,
                    children: topChildren,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SlideToConfirmButton(
                visible: true,
                title: 'Slide to add',
                resetOnSuccess: true,
                width: MediaQuery.of(context).size.width - 32,
                onConfirmed: _onAddTask,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
