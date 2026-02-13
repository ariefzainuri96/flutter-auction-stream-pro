class AuctionItemModel {
  final String? id;
  final String? itemName;
  final double? currentBid;
  final String? imageUrl;
  final String? hostUsername;
  final String? hostAvatarUrl;
  final int? viewerCount;
  final bool? isLive;
  final DateTime? startedAt;
  final int? hostId;

  AuctionItemModel({
    required this.id,
    required this.itemName,
    required this.currentBid,
    required this.imageUrl,
    required this.hostUsername,
    required this.hostAvatarUrl,
    required this.viewerCount,
    required this.isLive,
    required this.startedAt,
    required this.hostId,
  });

  factory AuctionItemModel.fromJson(Map<String, dynamic> json) =>
      AuctionItemModel(
        id: json['id'] as String,
        itemName: json['itemName'] as String,
        currentBid: (json['currentBid'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String,
        hostUsername: json['hostUsername'] as String,
        hostAvatarUrl: json['hostAvatarUrl'] as String,
        viewerCount: json['viewerCount'] as int,
        isLive: json['isLive'] as bool,
        startedAt: DateTime.parse(json['startedAt'] as String),
        hostId: json['hostId'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemName': itemName,
        'currentBid': currentBid,
        'imageUrl': imageUrl,
        'hostUsername': hostUsername,
        'hostAvatarUrl': hostAvatarUrl,
        'viewerCount': viewerCount,
        'isLive': isLive,
        'startedAt': startedAt?.toIso8601String(),
        'hostId': hostId,
      };

  AuctionItemModel copyWith({
    String? id,
    String? itemName,
    double? currentBid,
    String? imageUrl,
    String? hostUsername,
    String? hostAvatarUrl,
    int? viewerCount,
    bool? isLive,
    DateTime? startedAt,
    int? hostId,
  }) =>
      AuctionItemModel(
        id: id ?? this.id,
        itemName: itemName ?? this.itemName,
        currentBid: currentBid ?? this.currentBid,
        imageUrl: imageUrl ?? this.imageUrl,
        hostUsername: hostUsername ?? this.hostUsername,
        hostAvatarUrl: hostAvatarUrl ?? this.hostAvatarUrl,
        viewerCount: viewerCount ?? this.viewerCount,
        isLive: isLive ?? this.isLive,
        startedAt: startedAt ?? this.startedAt,
        hostId: hostId ?? this.hostId,
      );
}
