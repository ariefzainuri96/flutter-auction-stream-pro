import 'package:flutter/material.dart';
import '../../../cores/base/base_provider_view.dart';
import '../../../cores/constants/colors.dart';
import '../../../cores/constants/enums/page_state.dart';
import '../../../cores/routers/router_constant.dart';
import '../../../cores/utils/navigation_service.dart';
import '../../../cores/utils/size_helper.dart';
import '../../../cores/widgets/shared_input_field.dart';
import '../../lobby/model/lobby_view_data.dart';
import '../model/auction_list_notifier_data.dart';
import '../providers/auction_list_provider.dart';
import '../widgets/auction_card.dart';
import '../widgets/category_chip.dart';

class AuctionListView extends StatelessWidget {
  const AuctionListView({super.key});

  @override
  Widget build(BuildContext context) =>
      BaseProviderView<AuctionListNotifier, AuctionListNotifierData>(
        provider: auctionListProvider,
        backgroundColor: colors.backgroundDark,
        builder: (context, data, vm) => Column(
          children: [
            // Header
            _buildHeader(context),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SharedInputField(
                placeholder: 'Find items...',
                controller: vm.searchController,
                prefixIcon: Icons.search,
                onChanged: vm.updateSearch,
                suffixIcon: data.searchQuery.isNotEmpty ? Icons.clear : null,
                onSuffixTap: data.searchQuery.isNotEmpty
                    ? () {
                        vm.clearSearch();
                      }
                    : null,
              ),
            ),

            // Category Filters
            _buildCategoryFilters(data, vm),

            const SizedBox(height: 16),

            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    colors.surfaceBorder,
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: _buildContent(context, data, vm),
            ),
          ],
        ),
      );

  Widget _buildHeader(BuildContext context) => Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: const Text(
          'Live Auctions',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
      );

  Widget _buildCategoryFilters(
    AuctionListNotifierData data,
    AuctionListNotifier vm,
  ) {
    final categories = ['All', 'Electronics', 'Art', 'Sports', 'Fashion'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryChip(
            label: category,
            isSelected: data.selectedCategory == category,
            onTap: () => vm.selectCategory(category),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AuctionListNotifierData data,
    AuctionListNotifier vm,
  ) {
    // Loading state
    if (data.pageState == PageState.loading && data.auctions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading auctions...',
              style: TextStyle(
                fontSize: 16,
                color: colors.slate400,
              ),
            ),
          ],
        ),
      );
    }

    // Error state
    if (data.pageState == PageState.error && data.auctions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colors.red500,
            ),
            const SizedBox(height: 16),
            Text(
              data.errorMessage ?? 'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                color: colors.slate300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: vm.refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (data.pageState == PageState.empty || data.filteredAuctions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colors.slate400,
            ),
            const SizedBox(height: 16),
            Text(
              'No auctions found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.slate300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontSize: 14,
                color: colors.slate400,
              ),
            ),
          ],
        ),
      );
    }

    // Success state - Grid view with pull to refresh and infinite scroll
    return RefreshIndicator(
      onRefresh: vm.refresh,
      color: colors.primary,
      backgroundColor: colors.surfaceDark,
      child: Stack(
        children: [
          GridView.builder(
            controller: vm.scrollController,
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              // childAspectRatio: 0.575,
              mainAxisExtent: cardHeight,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
            ),
            itemCount:
                data.filteredAuctions.length + (data.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == data.filteredAuctions.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    ),
                  ),
                );
              }

              final auction = data.filteredAuctions[index];
              return AuctionCard(
                auction: auction,
                onTap: () {
                  final hostId = int.tryParse(
                        'host'.hashCode.toString().substring(0, 8),
                      ) ??
                      0;
                  const roomId = 'test-room1';

                  NavigationService.pushNamed(
                    Routes.lobby,
                    args: LobbyViewData(hostId: hostId, roomId: roomId),
                  );
                },
              );
            },
          ),

          // FAB button
          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton(
              onPressed: () {
                NavigationService.pushNamed(Routes.createAuction);
              },
              backgroundColor: colors.primary,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary,
                      const Color(0xFF7C3AED),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.videocam,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get cardHeight {
    double screenWidth = getScreenWidth;
    double padding = 32; // Total horizontal padding (e.g., 16 on each side)
    double spacing = 16; // Gap between columns
    double columnWidth = (screenWidth - padding - spacing) / 2;

    return (columnWidth * 1.25) + 86;
  }
}
