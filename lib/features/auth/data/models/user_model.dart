class UserModel {
  final int uid;
  final String name;
  final String username;
  final bool isInternalUser;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.isInternalUser,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userContext = json['user_context'] as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: json['uid'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      isInternalUser: json['is_internal_user'] ?? true,
    );
  }
}
