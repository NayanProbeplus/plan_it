// repositories/profile_repositories.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planit/models/profile_model.dart';

class ProfileRepository {
  static const _kName = 'profile_name';
  static const _kEmail = 'profile_email';
  static const _kGender = 'profile_gender';
  static const _kImagePath = 'profile_image_path'; // NEW

  Future<Profile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_kName) ?? '';
    final email = prefs.getString(_kEmail) ?? '';
    final gender = prefs.getString(_kGender) ?? 'Prefer not to say';
    final imagePath = prefs.getString(_kImagePath); // may be null
    return Profile(
        name: name, email: email, gender: gender, imagePath: imagePath);
  }

  Future<void> saveProfile(Profile p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, p.name);
    await prefs.setString(_kEmail, p.email);
    await prefs.setString(_kGender, p.gender);
    if (p.imagePath == null) {
      await prefs.remove(_kImagePath);
    } else {
      await prefs.setString(_kImagePath, p.imagePath!);
    }
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kName);
    await prefs.remove(_kEmail);
    await prefs.remove(_kGender);
    await prefs.remove(_kImagePath);
  }
}
