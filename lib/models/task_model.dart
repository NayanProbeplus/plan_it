// lib/models/task.dart
import 'package:isar/isar.dart';
part 'task_model.g.dart';

@Collection()
class Task {
  Id id = Isar.autoIncrement;

  late String name;
  late DateTime dueDate;
  late bool remind;
  late bool isCompleted;
  late DateTime createdAt;

  // Primary constructor (types must match for codegen)
  Task({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.dueDate,
    required this.remind,
    required this.isCompleted,
    required this.createdAt,
  });

  // Convenience factory that fills createdAt and defaults
  factory Task.create({
    Id? id,
    required String name,
    required DateTime dueDate,
    bool remind = true,
  }) {
    return Task(
      id: id ?? Isar.autoIncrement,
      name: name,
      dueDate: dueDate,
      remind: remind,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
  }
}
