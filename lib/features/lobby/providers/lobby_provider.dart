import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cores/constants/enums/page_state.dart';
import '../../../cores/routers/router_constant.dart';
import '../../../cores/utils/navigation_service.dart';
import '../model/lobby_request_model.dart';
import '../model/user_role.dart';

final lobbyProvider =
    NotifierProvider.autoDispose<LobbyNotifier, LobbyNotifierData>(
  LobbyNotifier.new,
);

class LobbyNotifier extends Notifier<LobbyNotifierData> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController roomIdController = TextEditingController();

  @override
  LobbyNotifierData build() {
    ref.onDispose(() {
      usernameController.dispose();
      roomIdController.dispose();
    });

    return LobbyNotifierData(
      request: LobbyRequestModel(),
      lobbyState: PageState.initial,
    );
  }

  void updateUsername(String value) {
    state = state.copyWith(
      request: state.request.copyWith(username: value),
    );
  }

  void updateRoomId(String value) {
    state = state.copyWith(
      request: state.request.copyWith(roomId: value),
    );
  }

  void updateRole(UserRole role) {
    state = state.copyWith(
      request: state.request.copyWith(role: role),
    );
  }

  void updateRequest(LobbyRequestModel value) {
    state = state.copyWith(request: value);
  }

  /// Enter the auction room
  Future<void> enterRoom() async {
    // Validate inputs
    if (!state.request.isValid) {
      debugPrint('Invalid lobby data: username and roomId are required');
      state = state.copyWith(lobbyState: PageState.error);
      return;
    }

    state = state.copyWith(lobbyState: PageState.loading);

    try {
      // TODO: Initialize Agora and Firebase services here
      debugPrint('Entering room with:');
      debugPrint('  Username: ${state.request.username}');
      debugPrint('  Room ID: ${state.request.roomId}');
      debugPrint('  Role: ${state.request.role.displayName}');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(lobbyState: PageState.success);

      // Navigate to auction room
      // TODO: Replace with actual route when implemented
      // NavigationService.pushNamed(Routes.auctionRoom);
      debugPrint('Navigation to auction room would happen here');
    } catch (e) {
      debugPrint('Error entering room: $e');
      state = state.copyWith(lobbyState: PageState.error);
    }
  }

  /// Test connection to services
  Future<void> testConnection() async {
    debugPrint('Testing Agora and Firebase connection...');
    // TODO: Implement connection test logic
  }

  /// Create a new room
  Future<void> createNewRoom() async {
    NavigationService.pushNamed(Routes.createAuction);
  }
}

class LobbyNotifierData {
  LobbyRequestModel request;
  PageState lobbyState;

  LobbyNotifierData({
    required this.request,
    required this.lobbyState,
  });

  LobbyNotifierData copyWith({
    LobbyRequestModel? request,
    PageState? lobbyState,
  }) =>
      LobbyNotifierData(
        request: request ?? this.request,
        lobbyState: lobbyState ?? this.lobbyState,
      );
}
