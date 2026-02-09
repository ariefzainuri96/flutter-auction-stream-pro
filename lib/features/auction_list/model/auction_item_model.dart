class AuctionItemModel {
  final String id;
  final String itemName;
  final double currentBid;
  final String imageUrl;
  final String hostUsername;
  final String hostAvatarUrl;
  final int viewerCount;
  final bool isLive;
  final String category;
  final DateTime startedAt;

  AuctionItemModel({
    required this.id,
    required this.itemName,
    required this.currentBid,
    required this.imageUrl,
    required this.hostUsername,
    required this.hostAvatarUrl,
    required this.viewerCount,
    required this.isLive,
    required this.category,
    required this.startedAt,
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
        category: json['category'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
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
        'category': category,
        'startedAt': startedAt.toIso8601String(),
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
    String? category,
    DateTime? startedAt,
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
        category: category ?? this.category,
        startedAt: startedAt ?? this.startedAt,
      );
}
