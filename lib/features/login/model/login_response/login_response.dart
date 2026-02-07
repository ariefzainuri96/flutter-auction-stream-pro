import 'dart:convert';

class LoginResponse {
  String? token;
  User? user;

  LoginResponse({this.token, this.user});

  factory LoginResponse.fromMap(Map<String, dynamic> data) => LoginResponse(
        token: data['token'] as String?,
        user: data['user'] == null
            ? null
            : User.fromMap(data['user'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'token': token,
        'user': user?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [LoginResponse].
  factory LoginResponse.fromJson(String data) =>
      LoginResponse.fromMap(json.decode(data) as Map<String, dynamic>);

  /// `dart:convert`
  ///
  /// Converts [LoginResponse] to a JSON string.
  String toJson() => json.encode(toMap());
}

class User {
  int? id;
  String? username;
  String? role;
  List<String>? allowedMenus;
  String? fcmToken;
  String? status;

  User({
    this.id,
    this.username,
    this.role,
    this.allowedMenus,
    this.fcmToken,
    this.status,
  });

  factory User.fromMap(Map<String, dynamic> data) => User(
        id: data['id'] as int?,
        username: data['username'] as String?,
        role: data['role'] as String?,
        allowedMenus: List<String>.from(data['allowed_menus'] ?? <String>[]),
        fcmToken: data['fcm_token'] as String?,
        status: data['status'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'role': role,
        'allowed_menus': allowedMenus,
        'fcm_token': fcmToken,
        'status': status,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [User].
  factory User.fromJson(String data) =>
      User.fromMap(json.decode(data) as Map<String, dynamic>);

  /// `dart:convert`
  ///
  /// Converts [User] to a JSON string.
  String toJson() => json.encode(toMap());
}
