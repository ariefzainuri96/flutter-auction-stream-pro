import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import '../model/auction_room_state.dart';

/// Agora RTM 2.x wrapper that handles chat, bid broadcasts, and speak flows.
class AgoraRtmService {
  final String appId;

  RtmClient? _client;
  String? _userId;
  String? _currentChannel;

  void Function(ChatMessageModel message)? onMessageReceived;
  void Function(SpeakRequestModel request)? onSpeakRequest;
  void Function(String userId, bool approved)? onSpeakRequestResponse;

  AgoraRtmService({required this.appId});

  /// Initialize the Agora RTM client instance
  Future<void> initialize({required String userId}) async {
    debugPrint('[AgoraRtmService] Initializing RTM client for $userId');
    if (_client != null) {
      debugPrint('[AgoraRtmService] RTM client already initialized');
      return;
    }

    _userId = userId;
    final (status, client) = await RTM(appId, userId);

    if (status.error) {
      throw Exception(
        'Failed to initialize Agora RTM: ${status.reason} (${status.errorCode})',
      );
    }

    _client = client;
    _client!.addListener(
      message: _handleMessageEvent,
      linkState: (event) {
        debugPrint('[AgoraRtmService] linkState: ${event.toJson()}');
      },
    );
  }

  /// Login to RTM using token
  Future<void> login({required String token, required String userId}) async {
    debugPrint('[AgoraRtmService] Logging in user: $userId');
    _userId = userId;

    if (_client == null) {
      throw Exception('RTM client must be initialized before login');
    }

    final (status, _) = await _client!.login(token);
    if (status.error) {
      throw Exception(
        'RTM login failed: ${status.reason} (${status.errorCode})',
      );
    }
  }

  /// Subscribe to the chat channel to receive events
  Future<void> joinChannel(String channelName) async {
    debugPrint('[AgoraRtmService] Subscribing to channel: $channelName');

    if (_client == null) {
      throw Exception('RTM client not initialized');
    }

    final (status, _) = await _client!.subscribe(
      channelName,
      withMessage: true,
      withMetadata: false,
      withPresence: false,
      withLock: false,
      beQuiet: false,
    );

    if (status.error) {
      throw Exception(
        'RTM subscribe failed: ${status.reason} (${status.errorCode})',
      );
    }

    _currentChannel = channelName;
  }

  /// Send a chat message to the current channel
  Future<void> sendChannelMessage(String text) async {
    if (_currentChannel == null) {
      debugPrint('[AgoraRtmService] No active channel to send chat message');
      return;
    }

    final payload = {
      'type': 'chat',
      'id': '${_userId ?? 'system'}-${DateTime.now().millisecondsSinceEpoch}',
      'userId': _userId ?? 'system',
      'username': _userId ?? 'system',
      'message': text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _publishEvent(
      _currentChannel!,
      payload,
      channelType: RtmChannelType.message,
      storeInHistory: false,
    );
  }

  /// Send a direct RTM payload to a peer user
  Future<void> sendPeerMessage({
    required Map<String, dynamic> data,
  }) async {
    if (_currentChannel == null) {
      debugPrint('[AgoraRtmService] No active channel to send chat message');
      return;
    }

    if (_client == null) {
      debugPrint('[AgoraRtmService] Cannot send peer message without client');
      return;
    }

    await _publishEvent(
      _currentChannel!,
      data,
      channelType: RtmChannelType.user,
    );
  }

  /// Audience -> Host: request microphone
  Future<void> requestToSpeak({
    required String username,
    String? avatarUrl,
  }) async {
    await sendPeerMessage(
      data: {
        'type': 'speak_request',
        'userId': _userId ?? username,
        'username': username,
        'avatarUrl': avatarUrl,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Host -> Audience: respond to a speak request
  Future<void> respondToSpeakRequest({
    required String userId,
    required bool approved,
  }) async {
    await sendPeerMessage(
      data: {
        'type': 'speak_response',
        'approved': approved,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Broadcast the latest bid to everyone
  Future<void> broadcastBidUpdate({
    required double amount,
    required String userId,
    required String username,
  }) async {
    if (_currentChannel == null) return;

    await _publishEvent(
      _currentChannel!,
      {
        'type': 'bid_update',
        'amount': amount,
        'userId': userId,
        'username': username,
        'timestamp': DateTime.now().toIso8601String(),
      },
      channelType: RtmChannelType.message,
    );
  }

  /// Stop listening to the channel
  Future<void> leaveChannel() async {
    if (_client == null || _currentChannel == null) return;

    final channel = _currentChannel!;
    debugPrint('[AgoraRtmService] Unsubscribing from $channel');
    final (status, _) = await _client!.unsubscribe(channel);
    if (status.error) {
      debugPrint(
        '[AgoraRtmService] Unsubscribe failed: ${status.reason} (${status.errorCode})',
      );
    }

    _currentChannel = null;
  }

  /// Logout from Agora RTM
  Future<void> logout() async {
    if (_client == null) return;

    debugPrint('[AgoraRtmService] Logging out RTM client');
    final (status, _) = await _client!.logout();
    if (status.error) {
      debugPrint(
        '[AgoraRtmService] Logout failed: ${status.reason} (${status.errorCode})',
      );
    }
  }

  /// Cleanup RTM resources
  Future<void> dispose() async {
    debugPrint('[AgoraRtmService] Disposing RTM service');
    await leaveChannel();
    await logout();

    if (_client != null) {
      try {
        await _client!.release();
      } catch (error) {
        debugPrint('[AgoraRtmService] Release failed: $error');
      }
      _client = null;
    }

    _currentChannel = null;
    _userId = null;
    debugPrint('[AgoraRtmService] Disposed');
  }

  void _handleMessageEvent(MessageEvent event) {
    final rawMessage = _decodeMessage(event.message);
    final payload = _tryParseMessage(rawMessage);
    final publisherId = event.publisher ?? _userId ?? 'unknown';
    final channelType = event.channelType ?? RtmChannelType.message;

    if (channelType == RtmChannelType.user) {
      _handlePeerEvent(publisherId, payload);
      return;
    }

    final chatMessage = _buildChatMessage(publisherId, rawMessage, payload);
    onMessageReceived?.call(chatMessage);
  }

  void _handlePeerEvent(String publisherId, Map<String, dynamic>? payload) {
    final type = (payload?['type'] as String?)?.toLowerCase();

    if (type == 'speak_request') {
      final request = SpeakRequestModel(
        userId: payload?['userId'] as String? ?? publisherId,
        username: payload?['username'] as String? ?? publisherId,
        avatarUrl: payload?['avatarUrl'] as String?,
        timestamp: _parseTimestamp(payload?['timestamp']),
      );
      onSpeakRequest?.call(request);
    } else if (type == 'speak_response') {
      final approved = payload?['approved'] as bool? ?? false;
      onSpeakRequestResponse?.call(publisherId, approved);
    }
  }

  ChatMessageModel _buildChatMessage(
    String publisherId,
    String rawMessage,
    Map<String, dynamic>? payload,
  ) {
    final timestamp = _parseTimestamp(payload?['timestamp']);
    final userId = payload?['userId'] as String? ?? publisherId;
    final username = payload?['username'] as String? ?? publisherId;
    final avatarUrl = payload?['avatarUrl'] as String?;
    final messageText = payload?['message'] as String? ?? rawMessage;
    final id = payload?['id'] as String? ??
        '$publisherId-${timestamp.millisecondsSinceEpoch}';
    final type = _chatMessageTypeFrom(payload?['type'] as String?);

    return ChatMessageModel(
      id: id,
      userId: userId,
      username: username,
      avatarUrl: avatarUrl,
      message: messageText,
      type: type,
      timestamp: timestamp,
    );
  }

  Future<void> _publishEvent(
    String channelName,
    Map<String, dynamic> payload, {
    required RtmChannelType channelType,
    bool storeInHistory = false,
  }) async {
    if (_client == null) {
      debugPrint('[AgoraRtmService] Cannot publish without RTM client');
      return;
    }

    try {
      final message = jsonEncode(payload);
      final (status, _) = await _client!.publish(
        channelName,
        message,
        channelType: channelType,
        storeInHistory: storeInHistory,
      );

      if (status.error) {
        debugPrint(
            '[AgoraRtmService] Publish failed: ${status.reason} (${status.errorCode})');
      }
    } catch (error) {
      debugPrint('[AgoraRtmService] Publish threw: $error');
    }
  }

  String _decodeMessage(Uint8List? data) {
    if (data == null) return '';
    try {
      return utf8.decode(data);
    } catch (_) {
      return '';
    }
  }

  Map<String, dynamic>? _tryParseMessage(String text) {
    if (text.isEmpty) return null;
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (error) {
      debugPrint('[AgoraRtmService] Failed to parse message payload: $error');
    }
    return null;
  }

  ChatMessageType _chatMessageTypeFrom(String? type) {
    switch (type?.toLowerCase()) {
      case 'system':
        return ChatMessageType.system;
      case 'bid':
        return ChatMessageType.bid;
      default:
        return ChatMessageType.text;
    }
  }

  DateTime _parseTimestamp(dynamic value) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
      final millis = int.tryParse(value);
      if (millis != null) return DateTime.fromMillisecondsSinceEpoch(millis);
    } else if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return DateTime.now();
  }
}
