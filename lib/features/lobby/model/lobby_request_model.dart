import 'user_role.dart';

class LobbyRequestModel {
  String? username;
  String? roomId;
  UserRole role;

  LobbyRequestModel({
    this.username,
    this.roomId,
    this.role = UserRole.viewer,
  });

  bool get isValid {
    return username != null &&
        username!.trim().isNotEmpty &&
        roomId != null &&
        roomId!.trim().isNotEmpty;
  }

  LobbyRequestModel copyWith({
    String? username,
    String? roomId,
    UserRole? role,
  }) {
    return LobbyRequestModel(
      username: username ?? this.username,
      roomId: roomId ?? this.roomId,
      role: role ?? this.role,
    );
  }
}
