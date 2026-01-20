import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planit/repositories/profile_repositories.dart';
import '../models/profile_model.dart';

// repository provider (singleton style)
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// AsyncValue<Profile> managed by a StateNotifier
class ProfileNotifier extends StateNotifier<AsyncValue<Profile>> {
  final ProfileRepository repo;
  ProfileNotifier(this.repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final p = await repo.loadProfile();
      state = AsyncValue.data(p);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> save(Profile p) async {
    // optimistic local update
    final previous = state;
    state = AsyncValue.data(p);
    try {
      await repo.saveProfile(p);
    } catch (e, st) {
      // rollback on failure
      state = previous;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateImagePath(String? path) async {
    final current = state.valueOrNull ??
        Profile(name: '', email: '', gender: 'Prefer not to say');
    final updated = current.copyWith(imagePath: path);
    await save(updated); // reuse save -> persists + updates state
  }

  Future<void> clear() async {
    await repo.clearProfile();
    state = AsyncValue.data(
        Profile(name: '', email: '', gender: 'Prefer not to say'));
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<Profile>>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repo);
});
