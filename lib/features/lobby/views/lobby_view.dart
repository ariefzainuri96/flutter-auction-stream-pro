import 'package:flutter/material.dart';
import '../../../cores/base/base_provider_view.dart';
import '../../../cores/constants/enums/page_state.dart';
import '../../../cores/utils/size_helper.dart';
import '../providers/lobby_provider.dart';
import '../../../cores/widgets/shared_input_field.dart';
import '../../../cores/widgets/glass_panel.dart';
import '../../../cores/widgets/primary_button.dart';
import '../../../cores/widgets/role_toggle.dart';
import '../../../cores/constants/colors.dart';

class LobbyView extends StatelessWidget {
  final int hostId;

  const LobbyView({
    super.key,
    required this.hostId,
  });

  @override
  Widget build(BuildContext context) => BaseProviderView(
        provider: lobbyProvider,
        builder: (context, data, notifier) => Stack(
          children: [
            // Ambient background gradient
            _buildBackgroundGradients(),

            // Main content
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 448), // max-w-md
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 32),

                          // Hero section
                          _buildHeroSection(),

                          const SizedBox(height: 32),

                          // Configuration card
                          SharedGlassPanel(
                            child: Column(
                              children: [
                                // Avatar preview
                                _buildAvatarPreview(),

                                const SizedBox(height: 24),

                                // Username input
                                SharedInputField(
                                  label: 'Username',
                                  placeholder: 'e.g. BidderOne',
                                  prefixIcon: Icons.badge_outlined,
                                  controller: notifier.usernameController,
                                  onChanged: notifier.updateUsername,
                                ),

                                const SizedBox(height: 24),

                                // Room ID input
                                SharedInputField(
                                  label: 'Room ID',
                                  placeholder: '883-291',
                                  prefixIcon: Icons.tag_outlined,
                                  suffixIcon: Icons.qr_code_scanner_outlined,
                                  controller: notifier.roomIdController,
                                  onChanged: notifier.updateRoomId,
                                  keyboardType: TextInputType.text,
                                  isMonospaced: true,
                                ),

                                const SizedBox(height: 24),

                                // Role toggle
                                SharedRoleToggle(
                                  selectedRole: data.request.role,
                                  onRoleChanged: notifier.updateRole,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Enter room button
                          SharedPrimaryButton(
                            text: 'Enter Room',
                            trailingIcon: Icons.login_outlined,
                            onPressed: () => notifier.enterRoom(0),
                            isLoading: data.lobbyState == PageState.loading,
                          ),

                          const SizedBox(height: 16),

                          // Footer links
                          _buildFooterLinks(notifier),

                          const SizedBox(height: 32),

                          // Powered by text
                          _buildPoweredBy(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildBackgroundGradients() => Positioned.fill(
        child: Stack(
          children: [
            // Bottom-right gradient
            Positioned(
              bottom: -200,
              right: -200,
              child: Container(
                width: getScreenWidth,
                height: getScreenHeight,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.primary.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Top-left gradient
            Positioned(
              top: 80,
              left: 40,
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.primaryLight.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildHeroSection() => Column(
        children: [
          const Text(
            'AuctionStream Pro Room Lobby',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Configure your settings to join the live atomic auction stream.',
            style: TextStyle(
              fontSize: 14,
              color: colors.slate400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );

  Widget _buildAvatarPreview() => Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.surfaceDark,
              border: Border.all(
                color: colors.surfaceBorder,
                width: 2,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.person_outline,
              color: colors.slate500,
              size: 36,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.backgroundDark,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      );

  Widget _buildFooterLinks(LobbyNotifier notifier) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: notifier.createNewRoom,
            child: const Text(
              'Create New Room',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: colors.slate600, // slate-600
              shape: BoxShape.circle,
            ),
          ),
          TextButton(
            onPressed: notifier.testConnection,
            child: const Text(
              'Test Connection',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      );

  Widget _buildPoweredBy() => Text(
        'POWERED BY ATOMIC SYNC',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.slate600, // slate-600
          letterSpacing: 1.5,
        ),
        textAlign: TextAlign.center,
      );
}
