import 'package:isar/isar.dart';
part 'payment_reminder.g.dart';

@Collection()
class PaymentReminder {
  Id id = Isar.autoIncrement;

  String paymentType;
  String name;
  double amount;
  String paymentOption;
  DateTime dueDate;
  DateTime createdAt;
  bool isPaid = false;

  // Primary constructor — types must match exactly for codegen
  PaymentReminder({
    this.id = Isar.autoIncrement,
    required this.paymentType,
    required this.name,
    required this.amount,
    required this.paymentOption,
    required this.dueDate,
    required this.createdAt,
  });

  // Convenience factory that fills createdAt with now()
  factory PaymentReminder.create({
    Id? id,
    required String paymentType,
    required String name,
    required double amount,
    required String paymentOption,
    required DateTime dueDate,
  }) {
    return PaymentReminder(
      id: id ?? Isar.autoIncrement,
      paymentType: paymentType,
      name: name,
      amount: amount,
      paymentOption: paymentOption,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
  }
}
