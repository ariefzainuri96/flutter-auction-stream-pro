import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cores/constants/enums/page_state.dart';
import '../providers/lobby_provider.dart';
import '../../../cores/widgets/custom_input_field.dart';
import '../../../cores/widgets/glass_panel.dart';
import '../../../cores/widgets/primary_button.dart';
import '../../../cores/widgets/role_toggle.dart';
import '../../../cores/constants/colors.dart';

class LobbyView extends ConsumerStatefulWidget {
  const LobbyView({super.key});

  @override
  ConsumerState<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends ConsumerState<LobbyView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lobbyState = ref.watch(lobbyProvider);
    final lobbyNotifier = ref.read(lobbyProvider.notifier);

    return Scaffold(
      backgroundColor: colors.backgroundDark,
      body: Stack(
        children: [
          // Ambient background gradient
          _buildBackgroundGradients(),

          // Main content
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448), // max-w-md
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        _buildHeader(context),

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
                                controller: _usernameController,
                                onChanged: lobbyNotifier.updateUsername,
                              ),

                              const SizedBox(height: 24),

                              // Room ID input
                              SharedInputField(
                                label: 'Room ID',
                                placeholder: '883-291',
                                prefixIcon: Icons.tag_outlined,
                                suffixIcon: Icons.qr_code_scanner_outlined,
                                controller: _roomIdController,
                                onChanged: lobbyNotifier.updateRoomId,
                                keyboardType: TextInputType.text,
                                isMonospaced: true,
                              ),

                              const SizedBox(height: 24),

                              // Role toggle
                              SharedRoleToggle(
                                selectedRole: lobbyState.request.role,
                                onRoleChanged: lobbyNotifier.updateRole,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Enter room button
                        SharedPrimaryButton(
                          text: 'Enter Room',
                          trailingIcon: Icons.login_outlined,
                          onPressed: lobbyNotifier.enterRoom,
                          isLoading: lobbyState.lobbyState == PageState.loading,
                        ),

                        const SizedBox(height: 16),

                        // Footer links
                        _buildFooterLinks(lobbyNotifier),

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
  }

  Widget _buildBackgroundGradients() => Positioned.fill(
      child: Stack(
        children: [
          // Bottom-right gradient
          Positioned(
            bottom: -200,
            right: -200,
            child: Container(
              width: 600,
              height: 400,
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

  Widget _buildHeader(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),

          // Logo and title
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary,
                      colors.primaryLight,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.gavel,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AuctionStream Pro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          // Spacer for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );

  Widget _buildHeroSection() => Column(
      children: [
        const Text(
          'Room Lobby',
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
