import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../cores/config/flavor_config.dart';

/// Firebase Realtime Database service for atomic bidding
class AuctionFirebaseService {
  DatabaseReference? _auctionRef;
  StreamSubscription? _bidSubscription;

  // Callbacks
  void Function(double newBid, String? bidderId, String? bidderAvatar)?
      onBidUpdated;
  void Function(String error)? onError;

  String get basePath =>
      FlavorConfig.instance?.flavor == Flavor.prod ? 'prod' : 'stage';

  /// Initialize the auction reference
  void initialize(String roomId) {
    debugPrint('[AuctionFirebaseService] Initializing for room: $roomId');

    final firebaseApp = Firebase.app();
    _auctionRef = FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL:
          'https://auction-stream-pro-default-rtdb.asia-southeast1.firebasedatabase.app/',
    ).ref('$basePath/auctions/$roomId');
  }

  /// Start listening to bid updates
  Future<void> listenToBids() async {
    if (_auctionRef == null) {
      debugPrint('[AuctionFirebaseService] Cannot listen: not initialized');
      return;
    }

    debugPrint(
      '[AuctionFirebaseService] Starting to listen for bid updates...',
    );

    _bidSubscription = _auctionRef!.child('currentBid').onValue.listen(
      (event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
          final bidderId = data['bidderId'] as String?;
          final bidderAvatar = data['bidderAvatar'] as String?;

          debugPrint(
            '[AuctionFirebaseService] Bid updated: \$$amount by $bidderId',
          );
          onBidUpdated?.call(amount, bidderId, bidderAvatar);
        }
      },
      onError: (error) {
        debugPrint('[AuctionFirebaseService] Error listening to bids: $error');
        onError?.call(error.toString());
      },
    );
  }

  /// Create initial auction data
  Future<void> createAuction({
    required String roomId,
    required double startingBid,
    required String itemName,
    required int hostId,
  }) async {
    debugPrint('[AuctionFirebaseService] Creating auction for room: $roomId');

    await _auctionRef?.set({
      'roomId': roomId,
      'itemName': itemName,
      'hostId': hostId,
      'startedAt': ServerValue.timestamp,
      'isLive': true,
      'currentBid': {
        'amount': startingBid,
        'bidderId': null,
        'bidderAvatar': null,
        'timestamp': ServerValue.timestamp,
      },
    });

    debugPrint('[AuctionFirebaseService] Auction created successfully');
  }

  /// Place a bid using Firebase Transaction (ATOMIC OPERATION)
  /// This prevents race conditions where multiple users bid simultaneously
  Future<BidResult> placeBid({
    required double bidAmount,
    required String userId,
    String? userAvatar,
  }) async {
    if (_auctionRef == null) {
      return BidResult(
        success: false,
        message: 'Auction not initialized',
      );
    }

    debugPrint(
      '[AuctionFirebaseService] Attempting to place bid: \$$bidAmount by $userId',
    );

    try {
      final bidRef = _auctionRef?.child('currentBid');

      // Use transaction to ensure atomic update
      final transactionResult =
          await bidRef?.runTransaction((Object? currentData) {
        if (currentData == null) {
          // First bid
          return Transaction.success({
            'amount': bidAmount,
            'bidderId': userId,
            'bidderAvatar': userAvatar,
            'timestamp': ServerValue.timestamp,
          });
        }

        final data = currentData as Map<dynamic, dynamic>;
        final currentBid = (data['amount'] as num?)?.toDouble() ?? 0.0;

        // Check if new bid is higher than current bid
        if (bidAmount <= currentBid) {
          debugPrint(
            '[AuctionFirebaseService] Bid rejected: \$$bidAmount <= \$$currentBid',
          );
          return Transaction.abort();
        }

        // Accept the bid
        debugPrint(
          '[AuctionFirebaseService] Bid accepted: \$$bidAmount > \$$currentBid',
        );
        return Transaction.success({
          'amount': bidAmount,
          'bidderId': userId,
          'bidderAvatar': userAvatar,
          'timestamp': ServerValue.timestamp,
        });
      });

      if (transactionResult?.committed ?? false) {
        debugPrint(
          '[AuctionFirebaseService] Transaction committed successfully',
        );
        return BidResult(
          success: true,
          message: 'Bid placed successfully',
          newBid: bidAmount,
        );
      } else {
        debugPrint(
          '[AuctionFirebaseService] Transaction aborted - bid too low',
        );
        return BidResult(
          success: false,
          message: 'Your bid is too low. Someone else bid higher!',
        );
      }
    } catch (e) {
      debugPrint('[AuctionFirebaseService] Error placing bid: $e');
      return BidResult(
        success: false,
        message: 'Failed to place bid: $e',
      );
    }
  }

  /// Get current bid
  Future<double> getCurrentBid() async {
    if (_auctionRef == null) return 0.0;

    try {
      final snapshot = await _auctionRef!.child('currentBid/amount').get();
      if (snapshot.exists) {
        return (snapshot.value as num).toDouble();
      }
    } catch (e) {
      debugPrint('[AuctionFirebaseService] Error getting current bid: $e');
    }

    return 0.0;
  }

  /// End the auction
  Future<void> endAuction() async {
    if (_auctionRef == null) return;

    debugPrint('[AuctionFirebaseService] Ending auction...');

    await _auctionRef!.update({
      'isLive': false,
      'endedAt': ServerValue.timestamp,
    });
  }

  /// Dispose and cleanup
  Future<void> dispose() async {
    debugPrint('[AuctionFirebaseService] Disposing...');
    await _bidSubscription?.cancel();
    _bidSubscription = null;
    _auctionRef = null;
  }
}

/// Result of a bid operation
class BidResult {
  final bool success;
  final String message;
  final double? newBid;

  BidResult({
    required this.success,
    required this.message,
    this.newBid,
  });
}
