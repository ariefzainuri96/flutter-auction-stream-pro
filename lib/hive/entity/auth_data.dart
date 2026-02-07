class AuthData {
  int? userId;
  String? token;
  String? role;
  String? password;

  AuthData({
    this.userId,
    this.token,
    this.role,
    this.password,
  });

  AuthData.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    token = json['token'];
    role = json['role'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['token'] = token;
    data['role'] = role;
    data['password'] = password;
    return data;
  }
}
