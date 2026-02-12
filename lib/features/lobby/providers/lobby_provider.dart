import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cores/constants/enums/page_state.dart';
import '../../../cores/routers/router_constant.dart';
import '../../../cores/utils/navigation_service.dart';
import '../../auction_stage/views/auction_stage_view.dart';
import '../model/lobby_request_model.dart';
import '../model/lobby_view_data.dart';

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

  void updateRequest(LobbyRequestModel value) {
    state = state.copyWith(request: value);
  }

  /// Enter the auction room
  Future<void> enterRoom(int hostId) async {
    // Validate inputs
    if (!state.request.isValid) {
      debugPrint('Invalid lobby data: username and roomId are required');
      state = state.copyWith(lobbyState: PageState.error);
      return;
    }

    state = state.copyWith(lobbyState: PageState.loading);

    await Future.delayed(const Duration(milliseconds: 600));

    state = state.copyWith(lobbyState: PageState.success);

    final data = AuctionStageViewData(
      roomId: state.request.roomId ?? '',
      uid: Random().nextInt(1 << 31),
      username: state.request.username ?? '',
      hostId: hostId,
    );

    NavigationService.pushNamed(Routes.auctionStage, args: data);
  }

  void initializeWithParams({required LobbyViewData args}) {
    roomIdController.text = args.roomId;
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
