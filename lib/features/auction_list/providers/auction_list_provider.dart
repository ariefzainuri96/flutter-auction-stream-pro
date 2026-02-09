import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cores/constants/enums/page_state.dart';
import '../model/auction_item_model.dart';
import '../model/auction_list_notifier_data.dart';

final auctionListProvider =
    NotifierProvider.autoDispose<AuctionListNotifier, AuctionListNotifierData>(
  AuctionListNotifier.new,
);

class AuctionListNotifier extends Notifier<AuctionListNotifierData> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

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
      filteredAuctions: [],
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
  Future<void> loadAuctions() async {
    if (state.pageState == PageState.loading) return;

    state = state.copyWith(
      pageState: PageState.loading,
      page: 1,
    );

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1200));

      final auctions = _getMockAuctions();

      if (auctions.isEmpty) {
        state = state.copyWith(
          pageState: PageState.empty,
          auctions: [],
          filteredAuctions: [],
        );
      } else {
        state = state.copyWith(
          pageState: PageState.success,
          auctions: auctions,
          filteredAuctions: _applyFilters(auctions),
          hasMore: auctions.length >= 10,
        );
      }
    } catch (e) {
      debugPrint('Error loading auctions: $e');
      state = state.copyWith(
        pageState: PageState.error,
        errorMessage: 'Failed to load auctions. Please try again.',
      );
    }
  }

  /// Load more auctions (lazy loading)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final newAuctions = _getMockAuctions(page: state.page + 1);
      final updatedAuctions = [...state.auctions, ...newAuctions];

      state = state.copyWith(
        auctions: updatedAuctions,
        filteredAuctions: _applyFilters(updatedAuctions),
        page: state.page + 1,
        hasMore: newAuctions.length >= 10,
        isLoadingMore: false,
      );
    } catch (e) {
      debugPrint('Error loading more auctions: $e');
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Update search query
  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFiltersAndUpdate();
  }

  void clearSearch() {
    searchController.clear();
    state = state.copyWith(searchQuery: '');
    _applyFiltersAndUpdate();
  }

  /// Update selected category
  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    _applyFiltersAndUpdate();
  }

  /// Apply filters and update state
  void _applyFiltersAndUpdate() {
    final filtered = _applyFilters(state.auctions);
    state = state.copyWith(
      filteredAuctions: filtered,
      pageState: filtered.isEmpty ? PageState.empty : PageState.success,
    );
  }

  /// Apply search and category filters
  List<AuctionItemModel> _applyFilters(List<AuctionItemModel> auctions) {
    var filtered = auctions;

    // Apply category filter
    if (state.selectedCategory != 'All') {
      filtered = filtered
          .where((auction) =>
              auction.category == state.selectedCategory.toLowerCase())
          .toList();
    }

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered
          .where((auction) =>
              auction.itemName
                  .toLowerCase()
                  .contains(state.searchQuery.toLowerCase()) ||
              auction.hostUsername
                  .toLowerCase()
                  .contains(state.searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  /// Refresh auctions
  Future<void> refresh() async {
    state = state.copyWith(page: 1, hasMore: true);
    await loadAuctions();
  }

  /// Mock data generator
  List<AuctionItemModel> _getMockAuctions({int page = 1}) {
    final baseIndex = (page - 1) * 10;

    final mockData = [
      {
        'itemName': 'Vintage Rolex Submariner',
        'currentBid': 12500.0,
        'imageUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDg7MYmmv5_ysUcQfmBVizhP6VS2QjkZIAYtfizmsjPpqkFZRQQn4E0XpEpZq4I0w4S8zRm_bPjGRjHZI-0HlFL9KSHgkYbCQk5qhGtt1Qf1hpkKnB6uWsAUHMwHukKozs3FbHPg91TsTx2teQI8ld4Kh-fm2wY6FwmHYwGiev4GyLOIBGpKRjuYO0OkHI72TYS4F6qLRj7kKsK58b4eN-67qnuj5nwFeLhW_sICy9AuFIDAWfOAK1OtKoVHsW9diO-79xrjdyorDOQ',
        'hostUsername': 'WatchGuy',
        'hostAvatarUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDkgloL7Iud--8QF-kQ7RaVuqgxtyTKULLlk4bqVrhAgw2u-vpMXcuhh3RX9WVfNq_8rMf26yA-h39GZs21UAqFzbJYGtF0TlLTywSioHEQowJPUUGA9NsqNBZkwbMrnsvdQtFy18IFVAFa0wE_8Zvl-Of3a1lNl44rFguKbeMbuy-tJ3gDKEFnpMaZ0D7Nz_6WCJsx1czDHVUcUz1DywnRaekvLFeWuAPzCOLfkH2hSj_VgycQApr3hToZTAqlRtjeyOMativlZgYh',
        'viewerCount': 240,
        'category': 'electronics',
      },
      {
        'itemName': 'Charizard 1st Edition',
        'currentBid': 4200.0,
        'imageUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuASJPY6qQmq81rYtijTcCEEeFEApRBSVVG-Gd7SuLxo2E1ghpW3LRLCuiXvf2pNGTuFzWWjcgFOjZLLe_DGIINlyFl3EsV2nnCutdGOnVTNj7BsT-4Kg0wSfB4h_9QkYv304_8pAEcHJQ2GuEmtGR4Hz17AD3yw4RDXLyPw2ZrGl6ETkNDPWFPsi2PzMe1TF9zhDdtmQPZlFsg7lFCvtmSB1R-Bk6CoeREUv0O7PWBkIh0fP4-vq2dlYyfrNKMYpuhEMZOpTsGVBhCo',
        'hostUsername': 'CardCollector',
        'hostAvatarUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuD3vIs8a87t8RgRfY1n9w085PZLOUuhV6V3HY2GKxowZkEYOzJFq5uFaLSDv6RCvtPw5JCIEInFRcOWe2Aw4hG49O1k5RJ9LQdKwLYqmMoIhVJuiqyQqS4vDflXryXPEenw2sF8Jnlazh42xTuOd5yuuw4xP4bDGJnzEB3q0TlXC51SM7apgQB0HVl2efGGPUuWE1Bd3odW5raBiDbhPKFFViRo2ReLopkiWqHbX-iUkev3pdnD9LgeG8_izPAsBCoXDUM9gp80-G1E',
        'viewerCount': 1200,
        'category': 'electronics',
      },
      {
        'itemName': 'Signed Jordan Jersey',
        'currentBid': 850.0,
        'imageUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuALuoybNAjHp_q1nwn817VktSr4xaKqINZgMUV7ZQ-7I3lj-2dhpwARemyTEnyA37mWLqMo5s98LKkGC5kD2E9LnjYmn9p1n02mXiJlsK8Zf2-8efvv6QH5lLAsE6Z83cdlogdwMA2BAeMsUepOyiBUvRQPd--yM6hQMX1jFbXXXpmu1qDvi7jDXYfQMZ7HGmMzsae-sl0xDLFU4Mi0xefkmayslHkW5Ry1q_GZXFsm2_kjtir1sCxzBvg2qDlcmzb2Mrni8kKWBVKv',
        'hostUsername': 'SportsMem',
        'hostAvatarUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDWNHXdlL8uTerMK9p2jdtFrFlg2uV5-ZhJOCiJAeBQ5hGsXP0qJAg-TaPZXOno9q_EkMKigr21hg_r8jLq_2JRZ9J4aKzIYKdE9dsu-Puwu-Ld0zZiobT2RjIsIgnN4oUnJ8yuFMrWhqy3749xioZmAWGO_ucr0Djo7_uJ0n8vUZ3nlBm5kZ7NyJ5kW13F63BVV6S2oUmmn_jsj9AZOoAXQhPIMIKt1cXaGeU1Cnv0IcdMyaqIzWULgr8N1t6coGifMWr2ci1iaVLz',
        'viewerCount': 85,
        'category': 'sports',
      },
      {
        'itemName': 'Gucci 1955 Bag',
        'currentBid': 1100.0,
        'imageUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCo1L8pwgzfFXIQLCA_yUc6Ld3BBs81nHb7zB0qdG4aEPj2G5jm-5uu4aXhSLfujCsa7Ou3pIHionfVY2j1LxW5vyNVX42niKg8oFdccMqyeMQ_d3xUOoiK6ZXlVdDcEcn3ssS6UPudUvqypGaqVzcqttZcbDUyiocH0keXSAdJS1Kpu9bDPRaPLPkCgwvS7nZ8RWLfk6YXBtkfZrF-NTBSU34m6mtzuMv96GOgFoOl20ZD0JHGFMFv6eRX0fEG3PPW2T1a1_qbtQSd',
        'hostUsername': 'LuxeLife',
        'hostAvatarUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAyijCrVptGXiw33GKSepHG_9-PuIK7iKDJDNDaj6-vbsRfNkEgHtuFerz4ExL3moBdDSVBcm9K_zJEbQLqqVXWoxtJJyaDKsD3ZrIxOyOiuK7Ipbs_76eo77kr-lovk9NxyBvPKfG-_-ttcK9D83nfhwu9R7nQeHRZCijI4-c0s5wT66le4pu76VeOOQJod_Ie78mlg9B4n1a2td8iDGdQAtJ0sk2S3sHiBKD6Im4Cf6s2ErhTub38MkOITJR77TY5h8DRv6Mwnu8m',
        'viewerCount': 342,
        'category': 'fashion',
      },
      {
        'itemName': 'Air Jordan 1 Retro',
        'currentBid': 320.0,
        'imageUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDlFs5sdwTUUwkh2MrNIL9Z8Grt7-8HHaykSSg6ty_wHge9o7ngLpBDSxcUQwhJVB5LtEgM5YCodn15I-qshnMoBw5P-NZ5V4BqOSuCD_7wwqcr9s7VBI7_lopj1m1G54hyS4QFZ1tcVFtIq3TSLNToBXs9EVo9C86xnXkZ417ecJAP3psLIW4Uxtmv-Dh1M-ag47sBfacvVUaB1r5Xa44SXg1H7MboKewC-RLMgeY5mefoD46y9eR7YwmqEzOr82P01Qo36fS10l7N',
        'hostUsername': 'SneakerHead',
        'hostAvatarUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAZsATWlaS9qyLi_T37XNhFnJ-0hDqeDuaqs01dHVVwG-9eFAD8viiLuO03TmO7xa48CB9SRexXEjB07LkPDs_DzvdusP15NFeC1eHELGlhYs0EM9jkRVKk9_6mpwTU_rm57bDDX_2L4uWcQiY7Yrg3N2r2YjJeejNbsqBJAlgBA6etGKB2_rmMi6Rgof4LNDDInB79mATdNj5DZwvPh5lAlCckJXkCxDVi2udKNF3cE0HtvrSpkZ10DVkMejmUKuVOj6sgFobnmD_1',
        'viewerCount': 56,
        'category': 'sports',
      },
      {
        'itemName': 'Abstract #42',
        'currentBid': 2400.0,
        'imageUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCfI8i9EWRVbZQDm8RWCm1zNawZipvbDqSnijNcANaaM8omB8ilLA6RfS5u2N3DlkDI42lTeSczBnt0mFk26vzsObk1XKO05okHdwJ_YSr6Qzdd_iwX5tEnznCl-GyG5viOqLNkxIlntpoGKEzC8fBHmHw7SJZlFw87ma4Na4DY5mFH4EbPQu7eebKANG8GbAljquYnkalGyxjYjMKEswVAjsK8Lw68o6yefmY0oxJl1G1rfF8uYvrIbY9CAXGjOWm0RbytqrDQJR4t',
        'hostUsername': 'ArtGallery',
        'hostAvatarUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCo_tHnpUlyYrLDe2YpcufBfGZwEfhRGYumI0SZk-oG4mzJDgbU_zfu-jY5MiKh0UsaBStIYTME1q6Q9LmkVXyOZ5LZ_locru57KfWLjY9yrubXwYjpdYGKXCsWBi8NRBzky3MjfuTIIHQWWvP8dtHlKCNqwoPWekRIzUM7boGUD-e9DiYXFIhy6fNjZYkQ0aMfeEQyX6NVe1lWBQvaDh6eWu06wsPAelsMjDvXrRznxa2B-Kf2ARRwlXeVwdBxYLqAMr__vb_9-fmd',
        'viewerCount': 112,
        'category': 'art',
      },
    ];

    return mockData.asMap().entries.map((entry) {
      final index = baseIndex + entry.key;
      final data = entry.value;

      return AuctionItemModel(
        id: 'auction_$index',
        itemName: data['itemName'] as String,
        currentBid: data['currentBid'] as double,
        imageUrl: data['imageUrl'] as String,
        hostUsername: data['hostUsername'] as String,
        hostAvatarUrl: data['hostAvatarUrl'] as String,
        viewerCount: data['viewerCount'] as int,
        isLive: true,
        category: data['category'] as String,
        startedAt: DateTime.now().subtract(Duration(minutes: index * 5)),
      );
    }).toList();
  }
}
