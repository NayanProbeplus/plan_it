// lib/providers/tasks_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:planit/services/isar_services.dart';
import 'package:planit/models/task_model.dart';

final tasksStreamProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  // Primary: watch the collection query (sorted by dueDate descending for example).
  // Adjust the query if you want different sorting / filtering.
  try {
    final stream = IsarService.isar.tasks.where().watch(fireImmediately: true);
    return stream;
  } catch (_) {
    // Fallback: if watch() doesn't return Stream<List<Task>>, convert a change-stream
    // into a mapped stream that queries the DB on each change.
    // The fallback (below) uses watchLazy() or watchObject? Replace as per your Isar version.
    final changeStream =
        IsarService.isar.tasks.watchLazy(fireImmediately: true); // may exist
    return changeStream
        .asyncMap((_) => IsarService.isar.tasks.where().findAll());
  }
});

// total tasks count (async)
final totalTasksCountProvider = FutureProvider<int>((ref) async {
  final list = await ref.watch(tasksStreamProvider.future);
  return list.length;
});
// pending/open tasks count (async) — tasks where isCompleted != true
final pendingTasksCountProvider = FutureProvider<int>((ref) async {
  final list = await ref.watch(tasksStreamProvider.future);
  final pending = list.where((t) => t.isCompleted != true).length;
  return pending;
});
