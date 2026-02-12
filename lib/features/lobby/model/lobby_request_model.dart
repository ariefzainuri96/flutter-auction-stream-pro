import 'user_role.dart';

class LobbyRequestModel {
  String? username;
  String? roomId;

  LobbyRequestModel({
    this.username,
    this.roomId,
  });

  bool get isValid =>
      username != null &&
      username!.trim().isNotEmpty &&
      roomId != null &&
      roomId!.trim().isNotEmpty;

  LobbyRequestModel copyWith({
    String? username,
    String? roomId,
    UserRole? role,
  }) =>
      LobbyRequestModel(
        username: username ?? this.username,
        roomId: roomId ?? this.roomId,
      );
}
