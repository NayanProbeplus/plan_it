// lib/routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:planit/screens/create/task/add_task_screen.dart';
import 'package:planit/screens/splash/splash_screen.dart';
import 'package:planit/screens/home/home.dart';
import 'package:planit/screens/profile/profile_screen.dart';
import 'package:planit/screens/create/payment/add_payment_screen.dart';
import 'package:planit/screens/stats/payment/payment_display_screen.dart';
import 'package:planit/screens/stats/tasks/task_display_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String profile = '/profile';

  static const String addPayment = '/addPayment';
  static const String addTask = '/addTask';

  static const String paymentDisplay = '/paymentDisplay';
  static const String taskDisplay = '/taskDisplay';
}

/// App-wide GoRouter instance
final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: <GoRoute>[
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),

    GoRoute(
      path: Routes.paymentDisplay,
      name: 'paymentDisplay',
      builder: (context, state) => const PaymentDisplayScreen(),
    ),

    GoRoute(
      path: Routes.taskDisplay,
      name: 'taskDisplay',
      builder: (context, state) => const TaskDisplayScreen(),
    ),
//----------------------------------------------
    // Example with a custom page transition for AddPayment
    GoRoute(
      path: Routes.addPayment,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const AddPaymentScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // simple fade + slide up
            final offset = Tween<Offset>(
                    begin: const Offset(0, 0.05), end: Offset.zero)
                .animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut));
            final opacity = animation;
            return SlideTransition(
              position: offset,
              child: FadeTransition(opacity: opacity, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        );
      },
    ),

    GoRoute(
      path: Routes.addTask,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const AddTaskScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // simple fade + slide up
            final offset = Tween<Offset>(
                    begin: const Offset(0, 0.05), end: Offset.zero)
                .animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut));
            final opacity = animation;
            return SlideTransition(
              position: offset,
              child: FadeTransition(opacity: opacity, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.location}')),
  ),
);
