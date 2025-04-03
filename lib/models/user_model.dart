class UserModel {
  final String name;
  final String email;
  final String? username;
  final String? bio;
  final String? profileImageUrl;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.name,
    required this.email,
    this.username,
    this.bio,
    this.profileImageUrl,
    this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"] ?? "User",
      email: json["email"] ?? "",
      username: json["username"],
      bio: json["bio"],
      profileImageUrl: json["profileImageUrl"],
      preferences: json["preferences"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "username": username,
      "bio": bio,
      "profileImageUrl": profileImageUrl,
      "preferences": preferences,
    };
  }
}