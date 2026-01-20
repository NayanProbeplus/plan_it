// lib/screens/home/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planit/core/router.dart';
import 'package:planit/providers/profile_provider.dart';
import 'package:planit/screens/calendar/calendar_screen.dart';
import 'package:planit/screens/create/quick_create.dart';
import 'package:planit/screens/home/bottom_nav_bar.dart';
import 'package:planit/screens/landing/today_overview_screen.dart';
import 'package:planit/screens/settings/sunrise_widget.dart';
import 'package:planit/screens/stats/stats_main_screen.dart';
import 'package:planit/theme/colors.dart';
import 'package:planit/theme/glass.dart';
import 'package:planit/utils/utilities.dart';
import 'package:planit/widgets/gradient_text.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int idx) {
    if (idx == 2) return;
    setState(() => _selectedIndex = idx);
  }

  void _onCenterTap() {
    setState(() => _selectedIndex = 2);
  }

  Widget _buildContent() {
    // pages for tabs
    final pages = [
      const TodayOverviewScreen(),
      const CalendarScreen(),
      const QuickCreateScreen(),
      const StatsCardsGrid(),
      const SunriseWidget(),
    ];
    return pages[_selectedIndex];
  }

  Widget _buildAppBarTitle({
    required int selectedIndex,
    required String Function() greetingText,
    required Color titleColor,
  }) {
    // HOME TAB → Greeting
    if (selectedIndex == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          Text(
            greetingText(),
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'MomoSignature',
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ],
      );
    }

    if (selectedIndex == 1) {
      return GradientText(
        'Calender',
        gradient: AppColors.darkAccentGradient,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFamily: 'Quicksand',
        ),
      );
    }

    if (selectedIndex == 3) {
      return GradientText(
        'Overview',
        gradient: AppColors.darkAccentGradient,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFamily: 'Quicksand',
        ),
      );
    }

    if (selectedIndex == 4) {
      return GradientText(
        'Theme',
        gradient: AppColors.darkAccentGradient,
        // gradient: AppColors.vibrantGradientBg,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFamily: 'Quicksand',
        ),
      );
    }
    // OTHER TABS → No title
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    // theme derived values
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    debugPrint('colour scheme in the home: $cs');
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final titleColor = cs.primary;
    final avatarInnerColor = cs.surface;

    // use provider for profile
    final profileAsync = ref.watch(profileNotifierProvider);

    String greetingText() {
      return profileAsync.maybeWhen(
        data: (p) {
          final name = p.name.trim();
          if (name.isNotEmpty) {
            final first = name.split(' ').first;
            return '${greeting()} $first';
          }
          return greeting();
        },
        orElse: () => greeting(),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: _buildAppBarTitle(
          selectedIndex: _selectedIndex,
          greetingText: greetingText,
          titleColor: titleColor,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () => context.push(Routes.profile),
              borderRadius: BorderRadius.circular(40),
              child: profileAsync.when(
                loading: () => Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isDark
                        ? AppColors.darkAccentGradient
                        : AppColors.vibrantGradientBg,
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Glass.borderColor(), width: 1.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                ),
                error: (e, st) => Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isDark
                        ? AppColors.darkAccentGradient
                        : AppColors.vibrantGradientBg,
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Glass.borderColor(), width: 1.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(3.0),
                    child: ProfileAvatar(
                      assetPath: 'assets/images/profile.jpg',
                      fallbackInitials: 'N',
                      networkFallback: 'https://example.com/default-avatar.png',
                      radius: 24,
                    ),
                  ),
                ),
                data: (profile) {
                  final imagePath = profile.imagePath;
                  final hasFile = imagePath != null &&
                      imagePath.isNotEmpty &&
                      File(imagePath).existsSync();

                  return Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isDark
                          ? AppColors.darkAccentGradient
                          : AppColors.vibrantGradientBg,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border:
                          Border.all(color: Glass.borderColor(), width: 1.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: ClipOval(
                        child: Container(
                          color: avatarInnerColor,
                          child: hasFile
                              ? Image.file(File(imagePath),
                                  width: 48, height: 48, fit: BoxFit.cover)
                              : ProfileAvatar(
                                  assetPath: 'assets/images/profile.jpg',
                                  fallbackInitials: profile.name.isNotEmpty
                                      ? profile.name[0].toUpperCase()
                                      : 'N',
                                  networkFallback:
                                      'https://example.com/default-avatar.png',
                                  radius: 24,
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildContent(),
          GlassBottomNav(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            onCenterTap: _onCenterTap,
          ),
        ],
      ),
    );
  }
}
