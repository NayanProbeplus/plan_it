// lib/screens/create/quick_create.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:planit/core/router.dart';
import 'package:planit/theme/colors.dart';
import 'package:planit/widgets/glass_edittexts_textfields.dart';
import 'package:planit/widgets/staggered_fade_animation.dart';

class QuickCreateScreen extends StatelessWidget {
  const QuickCreateScreen({super.key});

  void _onItemTap(BuildContext context, String type) {
    final snackTheme = Theme.of(context).snackBarTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type coming soon ✨',
            style: snackTheme.contentTextStyle ??
                const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: snackTheme.backgroundColor ?? Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // theme-aware color scheme
    final cs = Theme.of(context).colorScheme;
    final primaryText = cs.onSurface;
    final secondaryText = cs.onSurface.withOpacity(0.68);

    // match the staggered animation feel
    const topInitialDelay = Duration(milliseconds: 0);
    const delayBetween = Duration(milliseconds: 60); // Faster staggering
    const fadeDuration = Duration(milliseconds: 700); // Faster fade

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                24,
              ),
              child: StaggeredFade(
                initialDelay: topInitialDelay,
                delayBetween: delayBetween,
                fadeDuration: fadeDuration,
                curve: Curves.easeIn,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'What you want to add today?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Quicksand',
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 1. Notes
                  GlassInputWrapper(
                    child: _CreateOptionRow(
                      title: 'Notes',
                      icon: Icons.sticky_note_2_rounded,
                      iconColor: AppColors.warmAccentPurple,
                      onTap: () => _onItemTap(context, 'Notes'),
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Payment reminders
                  GlassInputWrapper(
                    child: _CreateOptionRow(
                      title: 'Payment reminders',
                      icon: Icons.payments_rounded,
                      iconColor: AppColors.mintCyan,
                      onTap: () {
                        context.push(Routes.addPayment);
                      },
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔔 3. Events & birthdays (recommended place for birthday reminders)
                  GlassInputWrapper(
                    child: _CreateOptionRow(
                      title: 'Events & birthdays',
                      icon: Icons.cake_rounded,
                      iconColor: AppColors.accentPink,
                      onTap: () => _onItemTap(context, 'Events & birthdays'),
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. Habits
                  GlassInputWrapper(
                    child: _CreateOptionRow(
                      title: 'Habits',
                      icon: Icons.repeat_rounded,
                      iconColor: AppColors.warmAccentClay,
                      onTap: () => _onItemTap(context, 'Habits'),
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. Goals
                  GlassInputWrapper(
                    child: _CreateOptionRow(
                      title: 'Goals',
                      icon: Icons.flag_rounded,
                      iconColor: AppColors.gold,
                      onTap: () => _onItemTap(context, 'Goals'),
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 6. Tasks
                  GlassInputWrapper(
                    child: _CreateOptionRow(
                      title: 'Tasks',
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.successGreen,
                      onTap: () => context.push(Routes.addTask),
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 7. Meetings
                  GlassInputWrapper(
                    child: _CreateOptionRow(
                      title: 'Meetings',
                      icon: Icons.event_available_rounded,
                      iconColor: AppColors.darkAccentBlue,
                      onTap: () => _onItemTap(context, 'Meetings'),
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateOptionRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final Color primaryText;
  final Color secondaryText;

  const _CreateOptionRow({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        // similar density to profile glass fields
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  fontFamily: 'Quicksand',
                  color: primaryText,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
