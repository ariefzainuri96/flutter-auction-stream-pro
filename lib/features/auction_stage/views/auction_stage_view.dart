import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cores/base/base_provider_view.dart';
import '../../../cores/constants/colors.dart';
import '../../../cores/utils/navigation_service.dart';
import '../../../cores/utils/size_helper.dart';
import '../../../cores/widgets/live_status_card.dart';
import '../model/auction_room_state.dart';
import '../providers/auction_stage_provider.dart';
import '../widgets/chat_overlay.dart';
import '../widgets/custom_bid_sheet.dart';

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

const double _kMinBidIncrement = 10;

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

              _buildBottomLayout(context, data, vm),

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

  Widget _buildBottomLayout(
    BuildContext context,
    AuctionRoomState data,
    AuctionStageNotifier vm,
  ) =>
      Positioned(
        left: 16,
        right: 16,
        bottom: getBottomPadding + 16,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChatPanel(data),
                const SizedBox(
                  width: 16,
                ),
                _buildActionColumn(context, vm, data),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            _buildChatInput(vm),
          ],
        ),
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
  Widget _buildTopHeader(
    BuildContext context,
    AuctionRoomState data,
    AuctionStageNotifier notifier,
  ) =>
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
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu,
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

  /// Build chat panel that mirrors the glass-card layout
  Widget _buildChatPanel(AuctionRoomState data) {
    final infoMessage =
        "${args.itemName ?? 'Auction item'}. Minimum bid increment is \$${_kMinBidIncrement.toInt()}";

    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        infoMessage,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.slate300,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.65),
                          Colors.black.withOpacity(0.25),
                        ],
                      ),
                    ),
                    child: ChatOverlay(
                      messages: data.messages,
                      height: 220,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionColumn(
    BuildContext context,
    AuctionStageNotifier vm,
    AuctionRoomState data,
  ) {
    final actions = <Widget>[];

    if (!data.isHost) {
      actions.add(_buildMicAction(vm, data));
      actions.add(const SizedBox(height: 12));
    }

    actions.add(_buildQuickBidIncrement(vm));
    actions.add(const SizedBox(height: 12));
    actions.add(_buildCustomBidButton(context, vm, data));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: actions,
    );
  }

  Widget _buildMicAction(AuctionStageNotifier vm, AuctionRoomState data) =>
      GestureDetector(
        onTap: () => vm.requestToSpeak(data.username ?? ''),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.mic,
            color: Colors.white,
            size: 28,
          ),
        ),
      );

  Widget _buildQuickBidIncrement(AuctionStageNotifier vm) => GestureDetector(
        onTap: () => vm.placeBid(10),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.accent, colors.accentHover],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_upward, color: Colors.white, size: 22),
              SizedBox(height: 4),
              Text(
                '+\$10',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildCustomBidButton(
    BuildContext context,
    AuctionStageNotifier vm,
    AuctionRoomState data,
  ) =>
      GestureDetector(
        onTap: () => _showCustomBidSheet(context, vm, data),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.edit_note,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(height: 4),
              Text(
                'Custom',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildChatInput(AuctionStageNotifier vm) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline, color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  cursorColor: colors.primary,
                  decoration: const InputDecoration(
                    hintText: 'Say something...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (value) => vm.sendChatMessage(value),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.send, color: colors.primary),
              ),
            ],
          ),
        ),
      );

  void _showCustomBidSheet(
    BuildContext context,
    AuctionStageNotifier vm,
    AuctionRoomState data,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => CustomBidSheet(
        currentBid: data.currentBid,
        minIncrement: _kMinBidIncrement,
        onPlaceBid: (amount) async {
          Navigator.of(sheetContext).pop();
          await vm.placeCustomBid(amount);
        },
        onClose: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

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
            onPressed: () => NavigationService.popXTimes(2),
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
