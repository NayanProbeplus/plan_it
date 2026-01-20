import 'dart:convert';

class Profile {
  final String name;
  final String email;
  final String gender;
  final String? imagePath;

  Profile({
    required this.name,
    required this.email,
    required this.gender,
    this.imagePath,
  });

  Profile copyWith({
    String? name,
    String? email,
    String? gender,
    String? imagePath, // MUST be added here
  }) {
    return Profile(
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'gender': gender,
        'imagePath': imagePath,
      };

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        name: m['name'] as String? ?? '',
        email: m['email'] as String? ?? '',
        gender: m['gender'] as String? ?? 'Prefer not to say',
        imagePath: m['imagePath'] as String?,
      );

  String toJson() => json.encode(toMap());
  factory Profile.fromJson(String s) => Profile.fromMap(json.decode(s));
}
