// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planit/core/router.dart';
import 'package:planit/widgets/sun_rise_controller.dart';
import 'package:planit/theme/colors.dart'; // <- import the central theme

class PlanItApp extends ConsumerWidget {
  const PlanItApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'PlanIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerDelegate: appRouter.routerDelegate,
      routeInformationParser: appRouter.routeInformationParser,
      routeInformationProvider: appRouter.routeInformationProvider,
    );
  }
}
