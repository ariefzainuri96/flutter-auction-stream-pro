import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cores/utils/firebase_helper.dart';
import '../../../cores/utils/navigation_service.dart';
import '../model/auction_room_state.dart';
import '../services/agora_rtc_service.dart';
import '../services/agora_rtm_service.dart';
import '../services/auction_firebase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Provider for the auction stage
final auctionStageProvider =
    NotifierProvider.autoDispose<AuctionStageNotifier, AuctionRoomState>(
  AuctionStageNotifier.new,
);

/// Auction Stage Notifier - Orchestrates RTC, RTM, and Firebase services
class AuctionStageNotifier extends Notifier<AuctionRoomState> {
  // Services
  late final AgoraRtcService _rtcService;
  late final AgoraRtmService _rtmService;
  late final AuctionFirebaseService _firebaseService;

  // Configuration (In production, get from environment or secure storage)
  static final String _agoraAppId = dotenv.env['AGORA_APP_ID'] ??
      'YOUR_AGORA_APP_ID'; // TODO: Replace with actual App ID

  @override
  AuctionRoomState build() {
    // Initialize services
    _rtcService = AgoraRtcService(appId: _agoraAppId);
    _rtmService = AgoraRtmService(appId: _agoraAppId);
    _firebaseService = AuctionFirebaseService();

    // Set up service callbacks
    _setupCallbacks();

    // Register dispose
    ref.onDispose(() {
      debugPrint('[AuctionStageNotifier] Disposing...');
      _dispose();
    });

    // Return initial state
    return const AuctionRoomState(
      roomId: '',
    );
  }

  /// Initialize with specific parameters
  void initializeWithParams({
    required String roomId,
    required int uid,
    required String username,
    required bool isHost,
    required int hostId,
    required String auctionImageUrl,
    double? startingBid,
    String? itemName,
  }) {
    state = state.copyWith(
      roomId: roomId,
      uid: uid,
      userRole: isHost ? UserRole.host : UserRole.audience,
      hostId: hostId,
      auctionImageUrl: auctionImageUrl,
      username: username,
    );

    // Start connection
    _connectToAuction(
      roomId: roomId,
      isHost: isHost,
      startingBid: startingBid,
      itemName: itemName,
    );
  }

  /// Setup callbacks for all services
  void _setupCallbacks() {
    // RTC callbacks
    _rtcService.onUserJoined = (connection, remoteUid, elapsed) {
      debugPrint('[AuctionStageNotifier] Remote user joined: $remoteUid');
    };

    _rtcService.onUserOffline = (connection, remoteUid, reason) {
      debugPrint('[AuctionStageNotifier] Remote user offline: $remoteUid');
    };

    _rtcService.onConnectionStateChanged = (connection, reason) {
      if (reason == ConnectionChangedReasonType.connectionChangedInterrupted) {
        state = state.copyWith(
          connectionState: AuctionConnectionState.reconnecting,
        );
      } else if (reason ==
          ConnectionChangedReasonType.connectionChangedJoinSuccess) {
        state = state.copyWith(
          connectionState: AuctionConnectionState.connected,
          isLive: true,
        );
      }
    };

    _rtcService.onError = (err, msg) {
      state = state.copyWith(
        errorMessage: 'RTC Error: $msg',
      );
    };

    // RTM callbacks
    _rtmService.onMessageReceived = _addMessage;

    _rtmService.onSpeakRequest = (request) {
      if (state.isHost) {
        final updatedRequests = [...state.speakRequests, request];
        state = state.copyWith(speakRequests: updatedRequests);
        _addSystemMessage('${request.username} requested to speak');
      }
    };

    _rtmService.onSpeakRequestResponse = (userId, approved) {
      if (approved) {
        _promoteToSpeaker();
        _addSystemMessage('Your request to speak was approved!');
      } else {
        _addSystemMessage('Your request to speak was denied');
      }
    };

    // Firebase callbacks
    _firebaseService.onBidUpdated = (newBid, bidderId, bidderAvatar) {
      state = state.copyWith(
        currentBid: newBid,
        highestBidderUserId: bidderId,
        highestBidderAvatar: bidderAvatar,
      );
    };

    _firebaseService.onError = (error) {
      state = state.copyWith(errorMessage: error);
    };
  }

  /// Connect to auction (RTC + RTM + Firebase)
  Future<void> _connectToAuction({
    required String roomId,
    required bool isHost,
    double? startingBid,
    String? itemName,
  }) async {
    try {
      state =
          state.copyWith(connectionState: AuctionConnectionState.connecting);

      final (rtcToken, rtmToken) = await generateToken(
        channelName: state.roomId,
        uid: state.uid ?? 0,
        role: isHost ? 'publisher' : 'subscriber',
      );

      // 1. Initialize RTC
      await _rtcService.initialize(isHost);

      // 2. Initialize RTM
      await _rtmService.initialize(userId: state.uid.toString());
      await _rtmService.login(token: rtmToken, userId: state.uid.toString());

      // 3. Join RTC channel
      await _rtcService.joinChannel(
        token: rtcToken,
        channelName: state.roomId,
        uid: state.uid ?? 0,
        isHost: isHost,
      );

      // 4. Join RTM channel
      await _rtmService.joinChannel(state.roomId);

      // 5. Initialize Firebase
      _firebaseService.initialize(state.roomId);

      // 6. If host, create auction in Firebase
      if (isHost && startingBid != null && itemName != null) {
        await _firebaseService.createAuction(
          roomId: state.roomId,
          startingBid: startingBid,
          itemName: itemName,
          hostId: state.hostId ?? 0,
          auctionImageUrl: state.auctionImageUrl ?? '',
          username: state.username ?? ''
        );
      }

      // 7. Start listening to bids
      await _firebaseService.listenToBids();

      // 8. Add welcome message
      _addSystemMessage(
          'Welcome to the auction! Starting bid: \$${startingBid ?? 0}');

      state = state.copyWith(
        connectionState: AuctionConnectionState.connected,
        isLive: true,
        currentBid: startingBid ?? 0,
      );

      debugPrint('[AuctionStageNotifier] Successfully connected to auction');
    } catch (e) {
      debugPrint('[AuctionStageNotifier] Error connecting: $e');
      state = state.copyWith(
        connectionState: AuctionConnectionState.failed,
        errorMessage: 'Failed to connect: $e',
      );
    }
  }

  /// Place a bid (atomic operation via Firebase Transaction)
  Future<void> placeBid(double incrementAmount) async {
    if (!state.isConnected) {
      _showError('Not connected to auction');
      return;
    }

    if (incrementAmount <= 0) {
      _showError('Bid must be higher than the current highest bid');
      return;
    }

    final currentBid = state.currentBid;
    final newBid = currentBid + incrementAmount;

    debugPrint(
        '[AuctionStageNotifier] Placing bid: \$${newBid.toStringAsFixed(0)}');

    final result = await _firebaseService.placeBid(
      bidAmount: newBid,
      userId: state.uid.toString(),
      userAvatar: null, // TODO: Add user avatar
    );

    if (result.success) {
      // Broadcast to all users via RTM
      await _rtmService.broadcastBidUpdate(
        amount: newBid,
        userId: state.uid.toString(),
        username: state.username ?? '', // TODO: Use actual username
      );

      debugPrint('[AuctionStageNotifier] Bid placed successfully');
    } else {
      _showError(result.message);
    }
  }

  Future<void> placeCustomBid(double amount) async {
    final incrementAmount = amount - state.currentBid;
    if (incrementAmount <= 0) {
      _showError('Bid must be higher than the current highest bid');
      return;
    }

    await placeBid(incrementAmount);
  }

  /// Request to speak (audience -> host)
  Future<void> requestToSpeak(String username) async {
    if (state.isHost) return;

    await _rtmService.requestToSpeak(
      username: username,
      avatarUrl: null, // TODO: Add avatar
    );

    _addSystemMessage('Request to speak sent to host');
  }

  /// Approve speak request (host only)
  Future<void> approveSpeakRequest(SpeakRequestModel request) async {
    if (!state.isHost) return;

    await _rtmService.respondToSpeakRequest(
      userId: request.userId,
      approved: true,
    );

    // Remove from pending requests
    final updatedRequests =
        state.speakRequests.where((r) => r.userId != request.userId).toList();
    state = state.copyWith(speakRequests: updatedRequests);

    _addSystemMessage('${request.username} can now speak');
  }

  /// Reject speak request (host only)
  Future<void> rejectSpeakRequest(SpeakRequestModel request) async {
    if (!state.isHost) return;

    await _rtmService.respondToSpeakRequest(
      userId: request.userId,
      approved: false,
    );

    // Remove from pending requests
    final updatedRequests =
        state.speakRequests.where((r) => r.userId != request.userId).toList();
    state = state.copyWith(speakRequests: updatedRequests);
  }

  /// Promote audience to speaker
  Future<void> _promoteToSpeaker() async {
    await _rtcService.updateClientRole(isHost: true);
    state = state.copyWith(userRole: UserRole.speaker);
  }

  /// Toggle microphone
  Future<void> toggleMicrophone() async {
    final newState = !state.isMicEnabled;
    await _rtcService.toggleMicrophone(newState);
    state = state.copyWith(isMicEnabled: newState);
  }

  /// Toggle camera
  Future<void> toggleCamera() async {
    final newState = !state.isCameraEnabled;
    await _rtcService.toggleCamera(newState);
    state = state.copyWith(isCameraEnabled: newState);
  }

  /// Send chat message
  Future<void> sendChatMessage(String text) async {
    // For simplicity, sending JSON-encoded message
    // In production, use a more robust protocol
    await _rtmService.sendChannelMessage(text);
  }

  /// Add message to chat
  void _addMessage(ChatMessageModel message) {
    final updatedMessages = [...state.messages, message];
    // Keep only last 50 messages to prevent memory issues
    if (updatedMessages.length > 50) {
      updatedMessages.removeAt(0);
    }
    state = state.copyWith(messages: updatedMessages);
  }

  /// Add system message
  void _addSystemMessage(String text) {
    final message = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'system',
      username: 'System',
      message: text,
      type: ChatMessageType.system,
      timestamp: DateTime.now(),
    );
    _addMessage(message);
  }

  /// Show error
  void _showError(String error) {
    state = state.copyWith(errorMessage: error);
    _addSystemMessage('Error: $error');
  }

  /// Get RTC engine for video rendering
  RtcEngine? getRtcEngine() => _rtcService.engine;

  /// Leave auction
  Future<void> leaveAuction() async {
    debugPrint('[AuctionStageNotifier] Leaving auction...');

    if (state.isHost) {
      await _firebaseService.endAuction();
    }

    await _dispose();

    NavigationService.pop();
  }

  /// Dispose all services
  Future<void> _dispose() async {
    await _rtcService.dispose();
    await _rtmService.dispose();
    await _firebaseService.dispose();
  }
}
