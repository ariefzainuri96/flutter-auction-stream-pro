import '../../../cores/constants/enums/page_state.dart';
import 'auction_item_model.dart';

class AuctionListNotifierData {
  final List<AuctionItemModel> auctions;
  final PageState pageState;
  final String selectedCategory;
  final String searchQuery;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  AuctionListNotifierData({
    required this.auctions,
    required this.pageState,
    required this.selectedCategory,
    required this.searchQuery,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    this.errorMessage,
  });

  AuctionListNotifierData copyWith({
    List<AuctionItemModel>? auctions,
    List<AuctionItemModel>? filteredAuctions,
    PageState? pageState,
    String? selectedCategory,
    String? searchQuery,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
  }) =>
      AuctionListNotifierData(
        auctions: auctions ?? this.auctions,
        pageState: pageState ?? this.pageState,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        searchQuery: searchQuery ?? this.searchQuery,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}