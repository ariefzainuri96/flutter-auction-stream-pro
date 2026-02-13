import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cores/constants/enums/page_state.dart';
import '../../auction_stage/services/auction_firebase_service.dart';
import '../model/auction_item_model.dart';
import '../model/auction_list_notifier_data.dart';

final auctionListProvider =
    NotifierProvider.autoDispose<AuctionListNotifier, AuctionListNotifierData>(
  AuctionListNotifier.new,
);

class AuctionListNotifier extends Notifier<AuctionListNotifierData> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final AuctionFirebaseService _firebaseService = AuctionFirebaseService();
  bool _isFetching = false;
  DateTime? _lastFetchedStartedAt;
  String? _lastSearchCursor;
  static const int _fetchLimit = 10;

  @override
  AuctionListNotifierData build() {
    ref.onDispose(() {
      searchController.dispose();
      scrollController.dispose();
    });

    // Initialize scroll listener for lazy loading
    scrollController.addListener(_onScroll);

    // Auto-load initial data
    Future.microtask(loadAuctions);

    return AuctionListNotifierData(
      auctions: [],
      pageState: PageState.initial,
      selectedCategory: 'All',
      searchQuery: '',
      page: 1,
      hasMore: true,
      isLoadingMore: false,
    );
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.8 &&
        !state.isLoadingMore &&
        state.hasMore &&
        state.pageState == PageState.success) {
      loadMore();
    }
  }

  /// Load initial auctions
  Future<void> loadAuctions() => _fetchPage(reset: true);

  /// Load more auctions (lazy loading)
  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.pageState != PageState.success) {
      return;
    }

    await _fetchPage(reset: false);
  }

  /// Update search query
  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    unawaited(_fetchPage(reset: true));
  }

  void clearSearch() {
    searchController.clear();
    state = state.copyWith(searchQuery: '');
    unawaited(_fetchPage(reset: true));
  }

  /// Refresh auctions
  Future<void> refresh() async {
    await _fetchPage(reset: true);
  }

  Future<void> _fetchPage({required bool reset}) async {
    if (_isFetching) return;

    final isSearch = state.searchQuery.isNotEmpty;
    if (!reset && (!state.hasMore || state.pageState != PageState.success)) {
      return;
    }

    _isFetching = true;

    if (reset) {
      _lastFetchedStartedAt = null;
      _lastSearchCursor = null;
      state = state.copyWith(
        auctions: [],
        filteredAuctions: [],
        pageState: PageState.loading,
        page: 1,
        hasMore: true,
        isLoadingMore: false,
        errorMessage: null,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, errorMessage: null);
    }

    try {
      final fetched = isSearch
          ? await _firebaseService.searchAuctions(
              query: state.searchQuery,
              limit: _fetchLimit,
              startAfterItemName: _lastSearchCursor,
            )
          : await _firebaseService.fetchAuctions(
              limit: _fetchLimit,
              startAfter: _lastFetchedStartedAt,
            );

      final updatedAuctions = reset ? fetched : [...state.auctions, ...fetched];
      final nextPageState =
          updatedAuctions.isEmpty ? PageState.empty : PageState.success;

      state = state.copyWith(
        auctions: updatedAuctions,
        pageState:
            reset && updatedAuctions.isEmpty ? PageState.empty : nextPageState,
        hasMore: fetched.length >= _fetchLimit,
        isLoadingMore: false,
        page: reset ? 1 : (fetched.isNotEmpty ? state.page + 1 : state.page),
        errorMessage: null,
      );

      if (fetched.isNotEmpty) {
        if (isSearch) {
          _lastSearchCursor = fetched.last.itemName;
        } else {
          _lastFetchedStartedAt = fetched.last.startedAt;
        }
      }
    } catch (e) {
      debugPrint('Error fetching auctions: $e');
      state = state.copyWith(
        pageState: PageState.error,
        errorMessage: 'Failed to load auctions. Please try again.',
        isLoadingMore: false,
      );
    } finally {
      _isFetching = false;
    }
  }
}
