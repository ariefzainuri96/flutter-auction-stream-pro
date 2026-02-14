import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../cores/config/flavor_config.dart';
import '../../auction_list/model/auction_item_model.dart';
import '../model/auction_room_state.dart';

/// Firebase Realtime Database service for atomic bidding
class AuctionFirebaseService {
  static const String _databaseUrl =
      'https://auction-stream-pro-default-rtdb.asia-southeast1.firebasedatabase.app/';
  DatabaseReference? _auctionRef;
  StreamSubscription? _bidSubscription;
  StreamSubscription? _bidHistorySubscription;

  // Callbacks
  void Function(double newBid, String? bidderId, String? bidderAvatar)?
      onBidUpdated;
  void Function(List<BidHistoryEntry> bidHistory)? onBidHistoryUpdated;
  void Function(String error)? onError;

  String get basePath =>
      FlavorConfig.instance?.flavor == Flavor.prod ? 'prod' : 'stage';

  /// Initialize the auction reference
  void initialize(String roomId) {
    debugPrint('[AuctionFirebaseService] Initializing for room: $roomId');

    final firebaseApp = Firebase.app();
    _auctionRef = FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL: _databaseUrl,
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
    required String auctionImageUrl,
    required String username,
  }) async {
    debugPrint('[AuctionFirebaseService] Creating auction for room: $roomId');

    await _auctionRef?.set({
      'roomId': roomId,
      'itemName': itemName,
      'hostId': hostId,
      'startedAt': ServerValue.timestamp,
      'username': username,
      'isLive': true,
      'auctionImageUrl': auctionImageUrl,
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
    required String username,
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

        // Add bid to history
        await _addBidToHistory(
          userId: userId,
          username: username,
          bidAmount: bidAmount,
          avatarUrl: userAvatar,
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

  /// Add bid to history
  Future<void> _addBidToHistory({
    required String userId,
    required String username,
    required double bidAmount,
    String? avatarUrl,
  }) async {
    if (_auctionRef == null) {
      debugPrint(
          '[AuctionFirebaseService] Cannot add bid to history: not initialized');
      return;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final bidId = '${timestamp}_$userId';

      await _auctionRef!.child('bidHistory/$bidId').set({
        'bidId': bidId,
        'userId': userId,
        'username': username,
        'avatarUrl': avatarUrl,
        'bidAmount': bidAmount,
        'timestamp': ServerValue.timestamp,
      });

      debugPrint(
        '[AuctionFirebaseService] Added bid to history: \$$bidAmount by $username',
      );
    } catch (e) {
      debugPrint(
        '[AuctionFirebaseService] Error adding bid to history: $e',
      );
    }
  }

  /// Start listening to bid history updates
  Future<void> listenToBidHistory() async {
    if (_auctionRef == null) {
      debugPrint(
          '[AuctionFirebaseService] Cannot listen to bid history: not initialized');
      return;
    }

    debugPrint(
      '[AuctionFirebaseService] Starting to listen for bid history updates...',
    );

    _bidHistorySubscription = _auctionRef!.child('bidHistory').onValue.listen(
      (event) async {
        try {
          final List<BidHistoryEntry> bidHistory = [];

          if (event.snapshot.exists) {
            final data = event.snapshot.value as Map<dynamic, dynamic>;

            for (final entry in data.entries) {
              final bidData = entry.value as Map<dynamic, dynamic>;
              try {
                final timestamp = bidData['timestamp'] is int
                    ? DateTime.fromMillisecondsSinceEpoch(
                        bidData['timestamp'] as int)
                    : DateTime.now();

                final bid = BidHistoryEntry(
                  bidId: bidData['bidId'] as String? ?? '',
                  userId: bidData['userId'] as String? ?? '',
                  username: bidData['username'] as String? ?? 'Unknown',
                  avatarUrl: bidData['avatarUrl'] as String?,
                  bidAmount: (bidData['bidAmount'] as num?)?.toDouble() ?? 0.0,
                  timestamp: timestamp,
                );

                bidHistory.add(bid);
              } catch (e) {
                debugPrint(
                    '[AuctionFirebaseService] Error parsing bid history entry: $e');
              }
            }

            // Sort by timestamp descending (newest first)
            bidHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

            // Keep only last 50 bids to prevent memory issues
            if (bidHistory.length > 50) {
              bidHistory.removeRange(50, bidHistory.length);
            }

            onBidHistoryUpdated?.call(bidHistory);

            debugPrint(
              '[AuctionFirebaseService] Bid history updated: ${bidHistory.length} bids',
            );
          }
        } catch (e) {
          debugPrint(
            '[AuctionFirebaseService] Error listening to bid history: $e',
          );
        }
      },
      onError: (error) {
        debugPrint(
            '[AuctionFirebaseService] Error listening to bid history: $error');
        onError?.call(error.toString());
      },
    );
  }

  /// Get bid history
  Future<List<BidHistoryEntry>> getBidHistory() async {
    if (_auctionRef == null) return [];

    try {
      final snapshot = await _auctionRef!.child('bidHistory').get();

      if (!snapshot.exists) return [];

      final List<BidHistoryEntry> bidHistory = [];
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (final entry in data.entries) {
        final bidData = entry.value as Map<dynamic, dynamic>;
        try {
          final timestamp = bidData['timestamp'] is int
              ? DateTime.fromMillisecondsSinceEpoch(bidData['timestamp'] as int)
              : DateTime.now();

          final bid = BidHistoryEntry(
            bidId: bidData['bidId'] as String? ?? '',
            userId: bidData['userId'] as String? ?? '',
            username: bidData['username'] as String? ?? 'Unknown',
            avatarUrl: bidData['avatarUrl'] as String?,
            bidAmount: (bidData['bidAmount'] as num?)?.toDouble() ?? 0.0,
            timestamp: timestamp,
          );

          bidHistory.add(bid);
        } catch (e) {
          debugPrint(
              '[AuctionFirebaseService] Error parsing bid history entry: $e');
        }
      }

      // Sort by timestamp descending (newest first)
      bidHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return bidHistory;
    } catch (e) {
      debugPrint('[AuctionFirebaseService] Error getting bid history: $e');
      return [];
    }
  }

  /// Dispose and cleanup
  Future<void> dispose() async {
    debugPrint('[AuctionFirebaseService] Disposing...');
    await _bidSubscription?.cancel();
    await _bidHistorySubscription?.cancel();
    _bidSubscription = null;
    _bidHistorySubscription = null;
    _auctionRef = null;
  }

  /// Add audience member to the auction
  Future<void> addAudienceMember({
    required String userId,
    required String username,
    String? avatarUrl,
    String role = 'viewer',
  }) async {
    if (_auctionRef == null) {
      debugPrint(
          '[AuctionFirebaseService] Cannot add audience: not initialized');
      return;
    }

    try {
      final timestamp = ServerValue.timestamp;

      await _auctionRef!.child('audience/$userId').set({
        'userId': userId,
        'username': username,
        'avatarUrl': avatarUrl,
        'joinedAt': timestamp,
        'role': role,
      });

      debugPrint(
        '[AuctionFirebaseService] Added audience member: $username ($userId)',
      );

      // Increment viewer count atomically
      await _incrementViewerCount();
    } catch (e) {
      debugPrint(
        '[AuctionFirebaseService] Error adding audience member: $e',
      );
    }
  }

  /// Remove audience member from the auction
  Future<void> removeAudienceMember(String userId) async {
    if (_auctionRef == null) {
      debugPrint(
          '[AuctionFirebaseService] Cannot remove audience: not initialized');
      return;
    }

    try {
      await _auctionRef!.child('audience/$userId').remove();

      debugPrint(
        '[AuctionFirebaseService] Removed audience member: $userId',
      );

      // Decrement viewer count atomically
      await _decrementViewerCount();
    } catch (e) {
      debugPrint(
        '[AuctionFirebaseService] Error removing audience member: $e',
      );
    }
  }

  /// Get all audience members
  Future<List<Map<String, dynamic>>> getAudienceMembers() async {
    if (_auctionRef == null) return [];

    try {
      final snapshot = await _auctionRef!.child('audience').get();

      if (!snapshot.exists) return [];

      final List<Map<String, dynamic>> members = [];
      for (final child in snapshot.children) {
        if (child.value is Map<dynamic, dynamic>) {
          final data = _normalizeData(child.value);
          members.add(data as Map<String, dynamic>);
        }
      }

      return members;
    } catch (e) {
      debugPrint('[AuctionFirebaseService] Error getting audience members: $e');
      return [];
    }
  }

  /// Increment viewer count atomically
  Future<void> _incrementViewerCount() async {
    if (_auctionRef == null) return;

    try {
      await _auctionRef!.child('viewerCount').runTransaction((Object? current) {
        int count = 0;
        if (current is int) {
          count = current;
        } else if (current is num) {
          count = current.toInt();
        }
        return Transaction.success(count + 1);
      });
    } catch (e) {
      debugPrint(
          '[AuctionFirebaseService] Error incrementing viewer count: $e');
    }
  }

  /// Decrement viewer count atomically
  Future<void> _decrementViewerCount() async {
    if (_auctionRef == null) return;

    try {
      await _auctionRef!.child('viewerCount').runTransaction((Object? current) {
        int count = 0;
        if (current is int) {
          count = current;
        } else if (current is num) {
          count = current.toInt();
        }
        return Transaction.success(max(0, count - 1));
      });
    } catch (e) {
      debugPrint(
          '[AuctionFirebaseService] Error decrementing viewer count: $e');
    }
  }

  DatabaseReference get _auctionsRootRef {
    final firebaseApp = Firebase.app();
    return FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL: _databaseUrl,
    ).ref('$basePath/auctions');
  }

  DatabaseReference? get audienceReference => _auctionRef?.child('audience');

  /// Fetch auctions in pages of [limit], optionally starting after [startAfter]
  Future<List<AuctionItemModel>> fetchAuctions({
    int limit = 10,
    DateTime? startAfter,
  }) async {
    Query query = _auctionsRootRef.orderByChild('startedAt');

    if (startAfter != null) {
      query = query.startAfter(startAfter.millisecondsSinceEpoch);
    }

    final snapshot = await query.limitToFirst(limit).get();
    return _mapSnapshotToAuctionList(snapshot);
  }

  /// Search auctions by item name prefix using Firebase query
  Future<List<AuctionItemModel>> searchAuctions({
    required String query,
    int limit = 10,
    String? startAfterItemName,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    Query searchQuery = _auctionsRootRef.orderByChild('startedAt');
    searchQuery =
        searchQuery.startAt(trimmedQuery).endAt('$trimmedQuery\uf8ff');

    if (startAfterItemName != null && startAfterItemName.isNotEmpty) {
      searchQuery = searchQuery.startAfter(startAfterItemName);
    }

    searchQuery = searchQuery.limitToFirst(limit);

    final snapshot = await searchQuery.get();
    return _mapSnapshotToAuctionList(snapshot);
  }

  List<AuctionItemModel> _mapSnapshotToAuctionList(DataSnapshot snapshot) =>
      snapshot.children
          .map((child) => _mapEntryToAuction(child.key, child.value))
          .whereType<AuctionItemModel>()
          .toList();

  AuctionItemModel? _mapEntryToAuction(dynamic key, dynamic value) {
    final data = _normalizeData(value);

    if (data is! Map<String, dynamic>) return null;

    if (data.isEmpty) return null;

    final id = data['roomId'] as String?;
    final itemName = data['itemName'] as String?;
    final imageUrl = data['auctionImageUrl'] as String?;
    final hostUsername = data['username'] as String?;
    final hostAvatar = data['hostAvatarUrl'] as String?;
    final viewerCount = _parseViewerCount(data['viewerCount']);
    final isLive = data['isLive'] as bool? ?? true;
    final startedAt = _parseStartedAt(data['startedAt'] as num?);
    final currentBid = _parseCurrentBid(data['currentBid']);
    final hostId = data['hostId'] as int?;

    return AuctionItemModel(
      id: id,
      itemName: itemName,
      currentBid: currentBid,
      imageUrl: imageUrl,
      hostUsername: hostUsername,
      hostAvatarUrl: hostAvatar,
      viewerCount: viewerCount,
      isLive: isLive,
      startedAt: startedAt,
      hostId: hostId,
    );
  }

  dynamic _normalizeData(dynamic value) {
    if (value is Map<dynamic, dynamic>) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return value;
  }

  int _parseViewerCount(dynamic raw) {
    try {
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      return 0;
    } catch (_) {
      return 0;
    }
  }

  double _parseCurrentBid(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is Map<dynamic, dynamic>) {
      final normalized = _normalizeData(raw);
      final amount = normalized['amount'];
      if (amount is num) return amount.toDouble();
    }
    return 0.0;
  }

  DateTime _parseStartedAt(dynamic raw) {
    if (raw is num) {
      return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    }

    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
      final asNum = num.tryParse(raw);
      if (asNum != null) {
        return DateTime.fromMillisecondsSinceEpoch(asNum.toInt());
      }
    }

    return DateTime.now();
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
