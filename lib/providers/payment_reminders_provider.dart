// lib/providers/reminders_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planit/models/payment_reminder.dart';
import 'package:isar/isar.dart';
import 'package:planit/services/isar_services.dart';

final isarProvider = Provider<Isar>((ref) => IsarService.isar);

// single shared filter provider
final paymentFilterProvider = StateProvider<String>((ref) => 'all');

final remindersStreamProvider =
    StreamProvider.autoDispose<List<PaymentReminder>>((ref) {
  final isar = ref.watch(isarProvider);
  final filter = ref.watch(paymentFilterProvider);

  // All
  if (filter == 'all') {
    return isar.paymentReminders.where().watch(fireImmediately: true);
  }

  // Paid
  if (filter == 'paid') {
    // NOTE: use .filter().isPaidEqualTo(...) followed by watch(...)
    return isar.paymentReminders
        .filter()
        .isPaidEqualTo(true)
        .watch(fireImmediately: true);
  }

  // Pending
  return isar.paymentReminders
      .filter()
      .isPaidEqualTo(false)
      .watch(fireImmediately: true);
});

/// Streams the number of pending (unpaid) payment reminders as an int.
/// Emits whenever the underlying query changes.
final pendingPaymentsCountProvider = StreamProvider.autoDispose<int>((ref) {
  final isar = ref.watch(isarProvider);

  // watch list of unpaid reminders and map to length
  return isar.paymentReminders
      .filter()
      .isPaidEqualTo(false)
      .watch(fireImmediately: true)
      .map((list) => list.length);
});

final totalPaymentsCountProvider = StreamProvider.autoDispose<int>((ref) {
  final isar = ref.watch(isarProvider);

  return isar.paymentReminders
      .where()
      .watch(fireImmediately: true)
      .map((list) => list.length);
});
