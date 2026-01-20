import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planit/app.dart';
import 'package:planit/services/isar_services.dart';
import 'package:planit/services/notification_service.dart';

void main() {
  // Optional: make zone errors fatal in debug (not required)
  // BindingBase.debugZoneErrorsAreFatal = true;

  runZonedGuarded(() async {
    // 1️⃣ Binding must be initialized INSIDE the same zone as runApp
    WidgetsFlutterBinding.ensureInitialized();

    // 2️⃣ Flutter error handler (still fine here)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      // send to crash reporter if you want
    };

    // 3️⃣ Lock orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 4️⃣ Init Isar
    try {
      await IsarService.init();
    } catch (e, st) {
      debugPrint('IsarService.init() failed: $e\n$st');
    }

    // 5️⃣ Init notifications
    try {
      await NotificationService.instance.init();
      // Android only right now, so no requestPermissions()
    } catch (e, st) {
      debugPrint('NotificationService.init() failed: $e\n$st');
    }

    // 6️⃣ Run app (same zone as ensureInitialized)
    runApp(const ProviderScope(child: PlanItApp()));
  }, (error, stack) {
    debugPrint('Uncaught error in runZonedGuarded: $error\n$stack');
    // send to crash reporter if desired
  });
}
