class CreateAuctionRequestModel {
  String? itemName;
  String? username;
  double? startingBid;
  String? photoPath;
  String? photoUrl;

  CreateAuctionRequestModel({
    this.itemName,
    this.startingBid,
    this.username,
    this.photoPath,
    this.photoUrl,
  });

  /// Validate that all mandatory fields are filled
  bool get isValid =>
      itemName != null &&
      itemName!.trim().isNotEmpty &&
      username != null &&
      username!.trim().isNotEmpty &&
      startingBid != null &&
      startingBid! >= 0 &&
      photoPath != null &&
      photoPath!.trim().isNotEmpty;

  /// Validation error messages
  String? get itemNameError {
    if (itemName == null || itemName!.trim().isEmpty) {
      return 'Item name is required';
    }
    return null;
  }

  String? get usernameError {
    if (username == null || username!.trim().isEmpty) {
      return 'Username is required';
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

  String? get photoError {
    if (photoPath == null || photoPath!.trim().isEmpty) {
      return 'Item photo is required';
    }
    return null;
  }

  CreateAuctionRequestModel copyWith({
    String? itemName,
    String? username,
    double? startingBid,
    String? photoPath,
    String? photoUrl,
  }) =>
      CreateAuctionRequestModel(
        itemName: itemName ?? this.itemName,
        username: username ?? this.username,
        startingBid: startingBid ?? this.startingBid,
        photoPath: photoPath ?? this.photoPath,
        photoUrl: photoUrl ?? this.photoUrl,
      );
}
