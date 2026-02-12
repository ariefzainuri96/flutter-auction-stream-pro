import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../cores/constants/colors.dart';
import '../model/auction_room_state.dart';

/// Replicates the auction menu designs from the provided mockups.
class AuctionMenuSheet extends StatefulWidget {
  final AuctionRoomState data;
  final Function() onEndOrLeavePressed;

  const AuctionMenuSheet({
    super.key,
    required this.data,
    required this.onEndOrLeavePressed,
  });

  @override
  State<AuctionMenuSheet> createState() => _AuctionMenuSheetState();
}

class _AuctionMenuSheetState extends State<AuctionMenuSheet> {
  List<_ParticipantData> get _participants {
    final seed = Uri.encodeComponent(widget.data.username ?? 'guest');
    final you = _ParticipantData(
      name: widget.data.username ?? 'You',
      status: widget.data.isHost ? 'Host' : 'Active bidder',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=$seed',
      tag: '#001',
      isOnline: true,
      isBidder: true,
    );
    return [you, ..._kSampleParticipants];
  }

  List<_BidEntry> get _bidHistory {
    final baseAmount = max(widget.data.currentBid, 100);
    final entries = <_BidEntry>[
      _BidEntry(
        username: widget.data.username ?? 'You',
        amount: widget.data.currentBid,
        timeAgo: 'Just now',
        label: widget.data.isHost ? 'Winning' : 'Winning',
        isWinning: true,
      ),
    ];

    for (final template in _kBidTemplates) {
      entries.add(
        _BidEntry(
          username: template.username,
          amount: max(baseAmount - template.offset, 50),
          timeAgo: template.timeAgo,
          label: template.label,
        ),
      );
    }

    return entries;
  }

  void _handleAction(BuildContext context) async {
    Navigator.of(context).pop();
    widget.onEndOrLeavePressed.call();
  }

  @override
  Widget build(BuildContext context) {
    final isHost = widget.data.isHost;
    return Material(
      color: Colors.transparent,
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.sheetBackground.withOpacity(0.95),
                    border: Border.all(color: colors.sheetBorder),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHandle(),
                      const SizedBox(height: 14),
                      if (isHost) ...[
                        _buildHeader(),
                        const SizedBox(height: 12),
                      ],
                      TabBar(
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Participants'),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: colors.sheetSurface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: colors.sheetBorder
                                            .withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    '${_participants.length}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Tab(text: 'Bids'),
                        ],
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: colors.primary.withOpacity(0.15),
                        ),
                        indicatorPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        labelColor: Colors.white,
                        unselectedLabelColor: colors.slate400,
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TabBarView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildParticipantsTab(),
                            _buildBidsTab(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(context, isHost),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() => Center(
        child: Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _buildHeader() => Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Host Controls',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  Widget _buildParticipantsTab() {
    final participants = _participants;
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: participants.length + 1,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == participants.length) {
          return Center(
            child: Text(
              'Showing ${participants.length} of 12 participants',
              style: TextStyle(fontSize: 12, color: colors.mutedText),
            ),
          );
        }
        return _buildParticipantCard(participants[index]);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }

  Widget _buildParticipantCard(_ParticipantData participant) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.sheetSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.sheetBorder.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(participant.avatarUrl),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.sheetSurface),
                    ),
                    child: Text(
                      participant.tag,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        participant.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: participant.isOnline
                              ? colors.accent
                              : colors.slate500,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    participant.status,
                    style: TextStyle(color: colors.mutedText, fontSize: 12),
                  ),
                ],
              ),
            ),
            _buildParticipantAction(Icons.block, 'Kick'),
          ],
        ),
      );

  Widget _buildParticipantAction(IconData icon, String tooltip) => DecoratedBox(
        decoration: BoxDecoration(
          color: colors.sheetBorder.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.sheetBorder.withOpacity(0.5)),
        ),
        child: IconButton(
          onPressed: () {},
          icon: Icon(icon, size: 18, color: colors.mutedText),
          tooltip: tooltip,
          splashRadius: 20,
        ),
      );

  Widget _buildBidsTab() {
    final bids = _bidHistory;
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: bids.length + 1,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == bids.length) {
          return Center(
            child: Text(
              'Displaying recent bids',
              style: TextStyle(fontSize: 12, color: colors.mutedText),
            ),
          );
        }
        final entry = bids[index];
        return entry.isWinning
            ? _buildTopBidCard(entry)
            : _buildHistoryBidCard(entry, index - 1);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }

  Widget _buildTopBidCard(_BidEntry entry) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.sheetSurface.withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.electricBlue.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: colors.electricBlue.withOpacity(0.15),
                  blurRadius: 18,
                  spreadRadius: -12,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  child: Text(
                    entry.username.substring(0, 1),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.timeAgo,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${entry.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.electricBlue),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Winning',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: -2,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.electricBlue,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Text(
                'Current High Bid',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colors.sheetBackground,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildHistoryBidCard(_BidEntry entry, int rank) {
    final amountColor =
        colors.electricBlue.withOpacity(_historyAmountOpacity(rank));
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.sheetSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.sheetBorder.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 46,
            width: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.sheetSurface.withOpacity(0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_circle,
                  color: Colors.white30, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.timeAgo,
                  style: TextStyle(color: colors.mutedText, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${entry.amount.toStringAsFixed(0)}',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: amountColor),
              ),
              const SizedBox(height: 4),
              Text(
                entry.label,
                style: TextStyle(color: colors.mutedText, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _historyAmountOpacity(int rank) {
    if (rank <= 0) return 0.9;
    if (rank == 1) return 0.7;
    return 0.5;
  }

  Widget _buildActionButton(BuildContext context, bool isHost) {
    final buttonBackground = isHost
        ? colors.red500.withOpacity(0.05)
        : colors.surfaceDark.withOpacity(0.6);
    final buttonForeground = isHost ? colors.red500 : Colors.white;
    final buttonBorderColor = colors.red500.withOpacity(isHost ? 0.5 : 0.7);

    return ElevatedButton.icon(
      onPressed: () => _handleAction(context),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: buttonBackground,
        foregroundColor: buttonForeground,
        side: BorderSide(color: buttonBorderColor),
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
      ),
      icon: Icon(isHost ? Icons.gavel : Icons.logout),
      label: Text(isHost ? 'End Auction' : 'Leave Auction'),
    );
  }
}

class _ParticipantData {
  final String name;
  final String status;
  final String avatarUrl;
  final String tag;
  final bool isOnline;
  final bool isBidder;

  const _ParticipantData({
    required this.name,
    required this.status,
    required this.avatarUrl,
    required this.tag,
    this.isOnline = true,
    this.isBidder = false,
  });
}

class _BidTemplate {
  final String username;
  final String timeAgo;
  final String label;
  final double offset;

  const _BidTemplate({
    required this.username,
    required this.timeAgo,
    required this.label,
    required this.offset,
  });
}

class _BidEntry {
  final String username;
  final double amount;
  final String timeAgo;
  final String label;
  final bool isWinning;

  const _BidEntry({
    required this.username,
    required this.amount,
    required this.timeAgo,
    required this.label,
    this.isWinning = false,
  });
}

const _kSampleParticipants = [
  _ParticipantData(
    name: 'Sarah Jenkins',
    status: 'Active bidder',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBDnESuuJaDah1mDSbPuxLtyRq4XBlFxN00OBVvrvdVNAW-Kx8XBYKpoGWXoVhP6DSqIUqRVPc95rsg-sNbagjVe1i8jKNMnj0snke307TYGwXcjz8t4g6HVJyQ96GY_-ggpQU9WkloYvNGHqLq6nsalsipDLhAzFQIyZYDeep5NC0ut67bETGkll6tc2hBrlox2fA_G3Uuiq8IKep-CW06Lid0bTghSST8YosZHFXiQQ4MuHtPXB1VGR2RWdRfz0g4vg2DQ4WBWCT7',
    tag: '#402',
  ),
  _ParticipantData(
    name: 'Michael Ross',
    status: 'Watching',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCJ0n3WjtwP3T84-QZQlEc580v_b4loqEWlL-id9AyKQ9pmJkusyuy38ydZKiuA17goqqELGPgXv2cVHHMEpFczBfITiHh6R9K204ETaj31btK5r5ngqyarY5vpWLBNwYMqHGbf15y-892LFTy0_AgKKmLnfU1EdBBYAVpNoNtLeOAZNCNoUAFSMiuFhQqnLbR_xihfUz14GsowEO6cnR55i6_NvWLm83WI6DiihOtzT1VVj9v9HZZus79vW330KXxd49aqB8aH0xVJ',
    tag: '#119',
  ),
  _ParticipantData(
    name: 'David Kim',
    status: 'Active bidder',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAf6I_4ZY3KfOvsXFLmb7fm6FL3lBePXNxDenBeFb3LdptSUK2s17g8T6YGfUgpN4jpCFB7XYmJq-4pRj-aXxKkBGi-wzcyTzCm9iNR5i4EgNEe_dW-h7WQCXHifGEsxYCoeLJRtHneXDL3ikjri1We_jL3neJOYSl3_ax1qfxAq72LVb7mr4yQ13pDVElj6odkyo3wmJ5l6bUnAm286RV-Spi5cAUYYYs5gZz63JzK6D0iHXmm2Vo5MKZPRpOzkZUyWH6_rQoUrtSC',
    tag: '#088',
  ),
  _ParticipantData(
    name: 'Elena Rodriguez',
    status: 'Watching',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB_FdC5M_SeWKzw-LKsBhQXMoyIbLf6LpW4rvZleQ2_MdXGruRIw6nzTo7wgDy9cW__jXcalRF-y94PxFOZInHaZg8ptIRmz-EdHDpXcpwNul1Ox1f20Qm9bUQ7IL_DW8RYQzCIAgBbpmsQYJEIHVW7PrJT8jFf5GN5XOmatBIa1G7vGyaTYUL9nQCJdQxkIqxY1spEVnu9HNs1nA8iObJ-pzEH914acpXoi62V6Q3p24XfEej88nmXe056wJRgPmZk64BrqS-oSARt',
    tag: '#512',
  ),
];

const _kBidTemplates = [
  _BidTemplate(
      username: 'David Kim', timeAgo: '2m ago', label: 'Outbid', offset: 250),
  _BidTemplate(
      username: 'Michael Ross',
      timeAgo: '5m ago',
      label: 'Outbid',
      offset: 550),
  _BidTemplate(
      username: 'Elena Rodriguez',
      timeAgo: '8m ago',
      label: 'Outbid',
      offset: 900),
];
