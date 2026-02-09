import 'package:equatable/equatable.dart';

/// Represents the auction room connection state
enum AuctionConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

/// User role in the auction
enum UserRole {
  host,
  audience,
  speaker, // Audience promoted to speaker
}

/// Main auction room state
class AuctionRoomState extends Equatable {
  final String roomId;
  final String? username;
  final UserRole userRole;
  final AuctionConnectionState connectionState;
  final double currentBid;
  final String? highestBidderUserId;
  final String? highestBidderAvatar;
  final List<ChatMessageModel> messages;
  final List<SpeakRequestModel> speakRequests;
  final bool isLive;
  final bool isMicEnabled;
  final bool isCameraEnabled;
  final String? errorMessage;
  final int? hostId;
  final int? uid;

  const AuctionRoomState({
    required this.roomId,
    this.username,
    this.userRole = UserRole.audience,
    this.connectionState = AuctionConnectionState.disconnected,
    this.currentBid = 0,
    this.highestBidderUserId,
    this.highestBidderAvatar,
    this.messages = const [],
    this.speakRequests = const [],
    this.isLive = false,
    this.isMicEnabled = false,
    this.isCameraEnabled = false,
    this.errorMessage,
    this.hostId,
    this.uid,
  });

  AuctionRoomState copyWith({
    String? roomId,
    UserRole? userRole,
    String? username,
    AuctionConnectionState? connectionState,
    double? currentBid,
    String? highestBidderUserId,
    String? highestBidderAvatar,
    List<ChatMessageModel>? messages,
    List<SpeakRequestModel>? speakRequests,
    bool? isLive,
    bool? isMicEnabled,
    bool? isCameraEnabled,
    String? errorMessage,
    int? hostId,
    int? uid,
  }) =>
      AuctionRoomState(
        username: username ?? this.username,
        roomId: roomId ?? this.roomId,
        userRole: userRole ?? this.userRole,
        connectionState: connectionState ?? this.connectionState,
        currentBid: currentBid ?? this.currentBid,
        highestBidderUserId: highestBidderUserId ?? this.highestBidderUserId,
        highestBidderAvatar: highestBidderAvatar ?? this.highestBidderAvatar,
        messages: messages ?? this.messages,
        speakRequests: speakRequests ?? this.speakRequests,
        isLive: isLive ?? this.isLive,
        isMicEnabled: isMicEnabled ?? this.isMicEnabled,
        isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
        errorMessage: errorMessage ?? this.errorMessage,
        hostId: hostId ?? this.hostId,
        uid: uid ?? this.uid,
      );

  bool get isHost => userRole == UserRole.host;
  bool get isSpeaker => userRole == UserRole.speaker;
  bool get isConnected => connectionState == AuctionConnectionState.connected;

  @override
  List<Object?> get props => [
        roomId,
        username,
        userRole,
        connectionState,
        currentBid,
        highestBidderUserId,
        highestBidderAvatar,
        messages,
        speakRequests,
        isLive,
        isMicEnabled,
        isCameraEnabled,
        errorMessage,
        hostId,
        uid,
      ];
}

/// Chat message model
class ChatMessageModel extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String message;
  final ChatMessageType type;
  final DateTime timestamp;

  const ChatMessageModel({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.message,
    this.type = ChatMessageType.text,
    required this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        username: json['username'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        message: json['message'] as String,
        type: ChatMessageType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ChatMessageType.text,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'username': username,
        'avatarUrl': avatarUrl,
        'message': message,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, userId, username, avatarUrl, message, type, timestamp];
}

/// Chat message types
enum ChatMessageType {
  text,
  system,
  bid,
}

/// Speak request model for Request to Speak feature
class SpeakRequestModel extends Equatable {
  final String userId;
  final String username;
  final String? avatarUrl;
  final DateTime timestamp;

  const SpeakRequestModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.timestamp,
  });

  factory SpeakRequestModel.fromJson(Map<String, dynamic> json) =>
      SpeakRequestModel(
        userId: json['userId'] as String,
        username: json['username'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'avatarUrl': avatarUrl,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  List<Object?> get props => [userId, username, avatarUrl, timestamp];
}
