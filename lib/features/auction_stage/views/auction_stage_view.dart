import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cores/base/base_provider_view.dart';
import '../../../cores/constants/colors.dart';
import '../../../cores/widgets/bid_button.dart';
import '../../../cores/widgets/live_status_card.dart';
import '../model/auction_room_state.dart';
import '../providers/auction_stage_provider.dart';
import '../widgets/chat_overlay.dart';

class AuctionStageViewData {
  final String roomId;
  final int uid;
  final String username;
  final bool isHost;
  final double? startingBid;
  final String? itemName;
  final int hostId;

  AuctionStageViewData({
    required this.roomId,
    required this.uid,
    required this.username,
    required this.hostId,
    this.isHost = false,
    this.startingBid,
    this.itemName,
  });
}

/// Auction Stage View - Main live auction screen
class AuctionStageView extends ConsumerWidget {
  final AuctionStageViewData args;

  const AuctionStageView({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      BaseProviderView<AuctionStageNotifier, AuctionRoomState>(
        provider: auctionStageProvider,
        backgroundColor: colors.backgroundDark,
        extendBodyBehindAppBar: true,
        useSafeArea: false,
        onPop: (vm, data) async {
          // Show confirmation dialog before leaving
          final shouldLeave = await _showLeaveConfirmation(context);
          if (shouldLeave) {
            await vm.leaveAuction();
            return true;
          }
          return false;
        },
        builder: (context, data, vm) {
          // Initialize on first build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (data.connectionState == AuctionConnectionState.disconnected) {
              vm.initializeWithParams(
                roomId: args.roomId,
                uid: args.uid,
                username: args.username,
                isHost: args.isHost,
                startingBid: args.startingBid,
                itemName: args.itemName,
                hostId: args.hostId,
              );
            }
          });

          return Stack(
            children: [
              // Full-screen video background
              _buildVideoLayer(vm, data),

              // Gradient overlays for readability
              _buildGradientOverlays(),

              // Top header with live status and highest bid
              _buildTopHeader(context, data, vm),

              // Chat overlay at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 140,
                child: ChatOverlay(messages: data.messages),
              ),

              // Bottom control bar
              _buildBottomControls(context, vm, data),

              // Loading indicator
              if (data.connectionState == AuctionConnectionState.connecting)
                _buildLoadingOverlay(),

              // Error snackbar
              if (data.errorMessage != null)
                _buildErrorBanner(context, data.errorMessage!),
            ],
          );
        },
      );

  /// Build video layer
  Widget _buildVideoLayer(AuctionStageNotifier vm, AuctionRoomState data) {
    final engine = vm.getRtcEngine();

    if (engine == null || !data.isConnected) {
      // Placeholder while connecting
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Render video view
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: data.isHost
          ? AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            )
          : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: engine,
                canvas: VideoCanvas(uid: data.hostId),
                connection: RtcConnection(channelId: data.roomId),
              ),
            ),
    );
  }

  /// Build gradient overlays
  Widget _buildGradientOverlays() => Positioned.fill(
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.2, 0.6, 1.0],
              ),
            ),
          ),
        ),
      );

  /// Build top header
  Widget _buildTopHeader(BuildContext context, AuctionRoomState data,
          AuctionStageNotifier notifier) =>
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Live status card with highest bid
                Flexible(
                  child: LiveStatusCard(
                    avatarUrl: data.highestBidderAvatar ??
                        'https://api.dicebear.com/7.x/avataaars/png?seed=${data.highestBidderUserId ?? "default"}',
                    highestBid: '\$${data.currentBid.toStringAsFixed(0)}',
                    isLive: data.isLive,
                  ),
                ),

                const SizedBox(width: 12),

                // Close button
                GestureDetector(
                  onTap: () async {
                    final shouldLeave = await _showLeaveConfirmation(context);

                    if (shouldLeave) {
                      await notifier.leaveAuction();
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.surfaceDark.withOpacity(0.85),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  /// Build bottom controls
  Widget _buildBottomControls(
    BuildContext context,
    AuctionStageNotifier vm,
    AuctionRoomState data,
  ) =>
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left: Like/Heart button
                _buildHeartButton(),

                const Spacer(),

                // Center: Request to Speak button
                if (!data.isHost)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildSpeakButton(vm, data),
                  ),

                const Spacer(),

                // Right: Bid button
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Quick bid presets (optional)
                      _buildQuickBidPresets(vm),

                      const SizedBox(height: 8),

                      // Main bid button
                      BidButton(
                        label: 'Quick Bid',
                        amountLabel: '+\$10',
                        onTap: () => vm.placeBid(10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  /// Build heart button
  Widget _buildHeartButton() => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.favorite,
          color: Colors.white,
          size: 24,
        ),
      );

  /// Build speak button
  Widget _buildSpeakButton(AuctionStageNotifier vm, AuctionRoomState data) =>
      GestureDetector(
        onTap: () {
          // TODO: Get host ID from room data
          vm.requestToSpeak(data.username ?? '');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Speak',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );

  /// Build quick bid presets
  Widget _buildQuickBidPresets(AuctionStageNotifier vm) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildPresetButton('\$50', () => vm.placeBid(50)),
          const SizedBox(width: 8),
          _buildPresetButton('\$100', () => vm.placeBid(100)),
        ],
      );

  /// Build preset button
  Widget _buildPresetButton(String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );

  /// Build loading overlay
  Widget _buildLoadingOverlay() => Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: colors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Connecting to auction...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  /// Build error banner
  Widget _buildErrorBanner(BuildContext context, String message) => Positioned(
        top: 100,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.red500,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );

  /// Show leave confirmation dialog
  Future<bool> _showLeaveConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surfaceDark,
        title: const Text(
          'Leave Auction?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to leave this auction?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Leave',
              style: TextStyle(color: colors.red500),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
