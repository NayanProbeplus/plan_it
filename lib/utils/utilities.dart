// lib/utils/utilities.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:planit/services/notification_service.dart';
import 'package:planit/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

String greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

class ProfileAvatar extends StatelessWidget {
  final String assetPath;
  final String fallbackInitials;
  final String? networkFallback;
  final double radius;

  const ProfileAvatar({
    required this.assetPath,
    required this.fallbackInitials,
    this.networkFallback,
    this.radius = 18,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final assetImage = AssetImage(assetPath);

    return FutureBuilder<bool>(
      future: _assetExists(context, assetImage),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return CircleAvatar(radius: radius, child: const SizedBox());
        }

        if (snap.data == true) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: assetImage,
            backgroundColor: Colors.transparent,
          );
        }

        if (networkFallback != null && networkFallback!.isNotEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            child: ClipOval(
              child: Image.network(
                networkFallback!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Center(child: Text(fallbackInitials)),
              ),
            ),
          );
        }

        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade300,
          child: Text(
            fallbackInitials,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: radius * 0.9,
            ),
          ),
        );
      },
    );
  }

  Future<bool> _assetExists(
      BuildContext context, ImageProvider provider) async {
    try {
      await precacheImage(provider, context);
      return true;
    } catch (_) {
      return false;
    }
  }
}

class AppToast {
  AppToast._(); // private constructor so no one can instantiate it

  static void show(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.accentPurple,
      textColor: AppColors.pastelTextDark,
      fontSize: 14.0,
    );
  }

  static void long(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.accentPurple,
      textColor: AppColors.pastelTextDark,
      fontSize: 14.0,
    );
  }
}

/// Schedules a reminder notification 2 days before the due date.
/// If the computed notifyAt is <= now, shows a notification immediately.
Future<void> scheduleOrShowReminderNotification({
  required int id, // use the Isar record id
  required String title,
  required String body,
  required DateTime dueDate,
}) async {
  final now = DateTime.now();
  final notifyAt = dueDate.subtract(const Duration(days: 2));

  // If notifyAt already passed (i.e. due within 2 days), show immediately.
  if (!notifyAt.isAfter(now)) {
    // small delay so user sees notification after UI finishes
    await NotificationService.instance.showNotification(
      id: id,
      title: title,
      body: body,
      payload: '$id',
    );
    return;
  }

  // otherwise schedule for notifyAt
  // Optionally nudge scheduled time a bit to avoid scheduling at midnight etc.
  final scheduled = notifyAt;

  await NotificationService.instance.scheduleNotification(
    id: id,
    title: title,
    body: body,
    scheduledDateLocal: scheduled,
    payload: '$id',
  );
}

const _kLastSplashDateKey = 'last_splash_date';

Future<bool> shouldShowSplashToday() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kLastSplashDateKey);
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal());
  return saved != today;
}

Future<void> markSplashShownToday() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal());
  await prefs.setString(_kLastSplashDateKey, today);
}
