import 'dart:io';
import 'package:flutter/material.dart';
import '../../../cores/base/base_provider_view.dart';
import '../../../cores/constants/colors.dart';
import '../../../cores/constants/enums/page_state.dart';
import '../../../cores/widgets/custom_input_field.dart';
import '../../../cores/widgets/hardware_check_row.dart';
import '../../../cores/widgets/primary_button.dart';
import '../providers/create_auction_provider.dart';

class CreateAuctionView extends StatelessWidget {
  const CreateAuctionView({super.key});

  @override
  Widget build(BuildContext context) => BaseProviderView(
        provider: createAuctionProvider,
        useSafeArea: false,
        builder: (context, data, notifier) => Stack(
          children: [
            Column(
              children: [
                // Header
                _buildHeader(context),

                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 100, // Space for fixed button
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Photo Upload Area
                        _buildPhotoUploadArea(context, data, notifier),

                        const SizedBox(height: 24),

                        // Form Fields
                        SharedInputField(
                          label: 'Item Name',
                          placeholder: 'e.g., Vintage Rolex 1970',
                          controller: notifier.itemNameController,
                          onChanged: (value) {
                            final updated = data.request.copyWith(
                              itemName: value,
                            );
                            notifier.updateData(updated);
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildStartingBidField(notifier, data),

                        const SizedBox(height: 16),

                        SharedInputField(
                          label: 'Auction Title',
                          placeholder: 'Enter a catchy title',
                          controller: notifier.auctionTitleController,
                          onChanged: (value) {
                            final updated = data.request.copyWith(
                              auctionTitle: value,
                            );
                            notifier.updateData(updated);
                          },
                        ),

                        const SizedBox(height: 24),

                        // Hardware Check Section
                        _buildHardwareCheckSection(data, notifier),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Fixed Bottom Action Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomActionButton(context, data, notifier),
            ),
          ],
        ),
      );

  /// Build Header with back button and title
  Widget _buildHeader(BuildContext context) => Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundDark.withOpacity(0.9),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: colors.slate300,
                  size: 20,
                ),
              ),
            ),

            // Title
            const Expanded(
              child: Text(
                'Setup Auction',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // Spacer to balance the back button
            const SizedBox(width: 36),
          ],
        ),
      );

  /// Build Photo Upload Area
  Widget _buildPhotoUploadArea(
    BuildContext context,
    CreateAuctionNotifierData data,
    CreateAuctionNotifier notifier,
  ) {
    final hasPhoto = data.request.photoPath != null;

    return GestureDetector(
      onTap: () => notifier.showPhotoSourceSelection(context),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 320),
          decoration: BoxDecoration(
            color: hasPhoto
                ? colors.surfaceDark
                : colors.surfaceDark.withOpacity(0.5),
            border: Border.all(
              color: hasPhoto
                  ? colors.surfaceBorder
                  : const Color(0xFF1E3A8A).withOpacity(0.5),
              width: hasPhoto ? 1 : 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: hasPhoto
              ? _buildPhotoPreview(data.request.photoPath!)
              : _buildPhotoPlaceholder(),
        ),
      ),
    );
  }

  /// Build Photo Preview
  Widget _buildPhotoPreview(String photoPath) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(photoPath),
              fit: BoxFit.cover,
            ),
            // Edit overlay
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Change Photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  /// Build Photo Placeholder
  Widget _buildPhotoPlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera Icon Circle
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_a_photo,
              color: colors.primary,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          // Primary Text
          const Text(
            'Add Item Photo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          // Secondary Text
          Text(
            'Tap to upload or take a picture',
            style: TextStyle(
              color: colors.slate400,
              fontSize: 12,
            ),
          ),
        ],
      );

  /// Build Starting Bid Field
  Widget _buildStartingBidField(
          CreateAuctionNotifier notifier, CreateAuctionNotifierData data) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Starting Bid (\$)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.slate300,
              ),
            ),
          ),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: colors.surfaceDark,
              border: Border.all(
                color: colors.surfaceBorder,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Dollar sign prefix
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 4),
                  child: Text(
                    '\$',
                    style: TextStyle(
                      color: colors.slate400,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Text field
                Expanded(
                  child: TextField(
                    controller: notifier.startingBidController,
                    onChanged: (value) {
                      final updated = data.request.copyWith(
                        startingBid: double.tryParse(value) ?? 0.0,
                      );
                      notifier.updateData(updated);
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        color: colors.slate500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  /// Build Hardware Check Section
  Widget _buildHardwareCheckSection(
    CreateAuctionNotifierData data,
    CreateAuctionNotifier notifier,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'HARDWARE CHECK',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.slate400,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Hardware Check Container
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceDark,
              border: Border.all(
                color: colors.surfaceBorder,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Microphone Row
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: HardwareCheckRow(
                    label: 'Microphone',
                    icon: Icons.mic,
                    enabled: data.request.microphoneEnabled,
                    onChanged: (value) {
                      final updated = data.request.copyWith(
                        microphoneEnabled: value,
                      );
                      notifier.updateData(updated);
                    },
                  ),
                ),

                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.surfaceBorder,
                  indent: 0,
                  endIndent: 0,
                ),

                // Camera Row
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: HardwareCheckRow(
                    label: 'Camera',
                    icon: Icons.videocam,
                    enabled: data.request.cameraEnabled,
                    onChanged: (value) {
                      final updated = data.request.copyWith(
                        cameraEnabled: value,
                      );
                      notifier.updateData(updated);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  /// Build Fixed Bottom Action Button
  Widget _buildBottomActionButton(
    BuildContext context,
    CreateAuctionNotifierData data,
    CreateAuctionNotifier notifier,
  ) =>
      Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundDark.withOpacity(0.95),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error message
            if (data.createState == PageState.error &&
                data.errorMessage != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colors.red500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.red500.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colors.red500,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.errorMessage!,
                        style: TextStyle(
                          color: colors.red500,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Button
            SharedPrimaryButton(
              text: 'Go Live & Start Auction',
              onPressed: notifier.goLiveAndStartAuction,
              isLoading: data.createState == PageState.loading,
              trailingIcon: Icons.live_tv,
            ),
          ],
        ),
      );
}
