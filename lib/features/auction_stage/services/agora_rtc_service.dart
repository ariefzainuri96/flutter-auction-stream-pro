import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Agora RTC Service for handling video/audio streaming
class AgoraRtcService {
  RtcEngine? _engine;
  final String appId;

  // Callbacks
  void Function(RtcConnection connection, int remoteUid, int elapsed)?
      onUserJoined;
  void Function(
    RtcConnection connection,
    int remoteUid,
    UserOfflineReasonType reason,
  )? onUserOffline;
  void Function(RtcConnection connection, RtcStats stats)? onLeaveChannel;
  void Function(RtcConnection connection, ConnectionChangedReasonType reason)?
      onConnectionStateChanged;
  void Function(ErrorCodeType err, String msg)? onError;

  AgoraRtcService({required this.appId});

  /// Initialize the Agora RTC Engine
  Future<void> initialize(bool isHost) async {
    debugPrint('[AgoraRtcService] Initializing with appId: $appId');

    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    // Create RTC Engine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    // Register event handlers
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint(
            '[AgoraRtcService] Successfully joined channel: ${connection.channelId}',
          );
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('[AgoraRtcService] User $remoteUid joined');
          onUserJoined?.call(connection, remoteUid, elapsed);
        },
        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
          debugPrint('[AgoraRtcService] User $remoteUid offline: $reason');
          onUserOffline?.call(connection, remoteUid, reason);
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint('[AgoraRtcService] Left channel');
          onLeaveChannel?.call(connection, stats);
        },
        onConnectionStateChanged: (
          RtcConnection connection,
          ConnectionStateType state,
          ConnectionChangedReasonType reason,
        ) {
          debugPrint(
            '[AgoraRtcService] Connection state changed: $state, reason: $reason',
          );
          onConnectionStateChanged?.call(connection, reason);
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('[AgoraRtcService] Error: $err, $msg');
          onError?.call(err, msg);
        },
      ),
    );

    // Enable video
    await _engine?.enableVideo();
    await _engine?.startPreview();
    await _engine?.muteLocalAudioStream(!isHost);

    debugPrint('[AgoraRtcService] Initialization complete');
  }

  /// Join a channel as broadcaster (host) or audience
  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
    required bool isHost,
  }) async {
    if (_engine == null) {
      throw Exception('Engine not initialized. Call initialize() first.');
    }

    debugPrint(
      '[AgoraRtcService] Joining channel: $channelName as ${isHost ? "HOST" : "AUDIENCE"}',
    );

    // Set client role
    await _engine!.setClientRole(
      role: isHost
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );

    // Set audio profile
    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioGameStreaming,
    );

    // Join channel
    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );

    debugPrint('[AgoraRtcService] Join channel request sent');
  }

  /// Leave the channel
  Future<void> leaveChannel() async {
    if (_engine == null) return;

    debugPrint('[AgoraRtcService] Leaving channel...');
    await _engine!.leaveChannel();
  }

  /// Update client role (promote audience to speaker)
  Future<void> updateClientRole({required bool isHost}) async {
    if (_engine == null) return;

    debugPrint(
      '[AgoraRtcService] Updating role to: ${isHost ? "BROADCASTER" : "AUDIENCE"}',
    );
    await _engine!.setClientRole(
      role: isHost
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );
  }

  /// Toggle microphone
  Future<void> toggleMicrophone(bool enabled) async {
    if (_engine == null) return;

    await _engine!.muteLocalAudioStream(!enabled);
    debugPrint(
      '[AgoraRtcService] Microphone ${enabled ? "enabled" : "disabled"}',
    );
  }

  /// Toggle camera
  Future<void> toggleCamera(bool enabled) async {
    if (_engine == null) return;

    await _engine!.muteLocalVideoStream(!enabled);
    debugPrint('[AgoraRtcService] Camera ${enabled ? "enabled" : "disabled"}');
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_engine == null) return;

    await _engine!.switchCamera();
    debugPrint('[AgoraRtcService] Camera switched');
  }

  /// Get the RTC Engine instance for rendering video
  RtcEngine? get engine => _engine;

  /// Dispose and release resources
  Future<void> dispose() async {
    if (_engine == null) return;

    debugPrint('[AgoraRtcService] Disposing RTC engine...');
    await _engine!.leaveChannel();
    await _engine!.release();
    _engine = null;
    debugPrint('[AgoraRtcService] Disposed');
  }
}
