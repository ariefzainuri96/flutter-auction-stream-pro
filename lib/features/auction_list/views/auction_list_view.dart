import 'package:flutter/gestures.dart';
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
        builder: (context, data, vm) => Stack(
          children: [
            Column(
              children: [
                // Header
                _buildHeader(context),

                // Search Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: SharedInputField(
                    placeholder: 'Find items...',
                    controller: vm.searchController,
                    prefixIcon: Icons.search,
                    onChanged: vm.updateSearch,
                    suffixIcon:
                        data.searchQuery.isNotEmpty ? Icons.clear : null,
                    onSuffixTap: data.searchQuery.isNotEmpty
                        ? () {
                            vm.clearSearch();
                          }
                        : null,
                  ),
                ),

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
    if (data.pageState == PageState.empty || data.auctions.isEmpty) {
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
            RichText(
              text: TextSpan(
                  text: 'Try adjusting your filters, or ',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.slate400,
                  ),
                  children: [
                    TextSpan(
                      text: 'Retry?',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = vm.refresh,
                    )
                  ]),
            )
          ],
        ),
      );
    }

    // Success state - Grid view with pull to refresh and infinite scroll
    return RefreshIndicator(
      onRefresh: vm.refresh,
      color: colors.primary,
      backgroundColor: colors.surfaceDark,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: vm.scrollController,
        padding: const EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // childAspectRatio: 0.575,
          mainAxisExtent: cardHeight,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
        ),
        itemCount: data.auctions.length + (data.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == data.auctions.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
            );
          }

          final auction = data.auctions[index];
          return Opacity(
            opacity: (auction.isLive ?? true) ? 1.0 : 0.65,
            child: AuctionCard(
              auction: auction,
              onTap: () {
                NavigationService.pushNamed(
                  Routes.lobby,
                  args: LobbyViewData(
                    hostId: auction.hostId ?? 0,
                    roomId: auction.id ?? '',
                  ),
                );
              },
            ),
          );
        },
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
