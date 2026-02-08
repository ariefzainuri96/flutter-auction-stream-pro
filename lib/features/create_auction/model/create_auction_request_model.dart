class CreateAuctionRequestModel {
  String? itemName;
  double? startingBid;
  String? auctionTitle;
  String? photoPath;
  bool microphoneEnabled;
  bool cameraEnabled;

  CreateAuctionRequestModel({
    this.itemName,
    this.startingBid,
    this.auctionTitle,
    this.photoPath,
    this.microphoneEnabled = true,
    this.cameraEnabled = true,
  });

  /// Validate that all mandatory fields are filled
  bool get isValid {
    return itemName != null &&
        itemName!.trim().isNotEmpty &&
        startingBid != null &&
        startingBid! >= 0 &&
        auctionTitle != null &&
        auctionTitle!.trim().isNotEmpty &&
        photoPath != null &&
        photoPath!.trim().isNotEmpty;
  }

  /// Validation error messages
  String? get itemNameError {
    if (itemName == null || itemName!.trim().isEmpty) {
      return 'Item name is required';
    }
    return null;
  }

  String? get startingBidError {
    if (startingBid == null) {
      return 'Starting bid is required';
    }
    if (startingBid! < 0) {
      return 'Starting bid must be positive';
    }
    return null;
  }

  String? get auctionTitleError {
    if (auctionTitle == null || auctionTitle!.trim().isEmpty) {
      return 'Auction title is required';
    }
    return null;
  }

  String? get photoError {
    if (photoPath == null || photoPath!.trim().isEmpty) {
      return 'Item photo is required';
    }
    return null;
  }

  CreateAuctionRequestModel copyWith({
    String? itemName,
    double? startingBid,
    String? auctionTitle,
    String? photoPath,
    bool? microphoneEnabled,
    bool? cameraEnabled,
  }) {
    return CreateAuctionRequestModel(
      itemName: itemName ?? this.itemName,
      startingBid: startingBid ?? this.startingBid,
      auctionTitle: auctionTitle ?? this.auctionTitle,
      photoPath: photoPath ?? this.photoPath,
      microphoneEnabled: microphoneEnabled ?? this.microphoneEnabled,
      cameraEnabled: cameraEnabled ?? this.cameraEnabled,
    );
  }
}
