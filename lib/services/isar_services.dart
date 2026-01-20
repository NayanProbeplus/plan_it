import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:planit/models/task_model.dart';
import '../models/payment_reminder.dart';

class IsarService {
  static late final Isar isar;

  /// Call this once at app startup (before runApp).
  static Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    isar = await Isar.open(
      [
        PaymentReminderSchema,
        TaskSchema,
      ],
      directory: dir.path,
    );
  }
}
