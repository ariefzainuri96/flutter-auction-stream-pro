import 'package:flutter/material.dart';
import '../../../cores/base/base_provider_view.dart';
import '../../../cores/constants/enums/page_state.dart';
import '../../../cores/utils/size_helper.dart';
import '../../../cores/widgets/text_app_bar.dart';
import '../model/lobby_view_data.dart';
import '../providers/lobby_provider.dart';
import '../../../cores/widgets/shared_input_field.dart';
import '../../../cores/widgets/glass_panel.dart';
import '../../../cores/widgets/primary_button.dart';
import '../../../cores/constants/colors.dart';

class LobbyView extends StatelessWidget {
  final LobbyViewData args;

  const LobbyView({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context) => BaseProviderView(
      provider: lobbyProvider,
      appBar: (vm, data) => const TextAppBar(
            title: 'Auction Lobby',
            isCenterTitle: false,
          ),
      builder: (context, data, vm) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          vm.initializeWithParams(
            args: args,
          );
        });

        return Stack(
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
                          const SizedBox(height: 8),

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
                                  controller: vm.usernameController,
                                  onChanged: (value) {
                                    final updated = data.request.copyWith(
                                      username: value,
                                    );
                                    vm.updateRequest(updated);
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Room ID input
                                SharedInputField(
                                  label: 'Room ID',
                                  placeholder: '883-291',
                                  prefixIcon: Icons.tag_outlined,
                                  suffixIcon: Icons.qr_code_scanner_outlined,
                                  controller: vm.roomIdController,
                                  onChanged: (value) {
                                    final updated = data.request.copyWith(
                                      roomId: value,
                                    );
                                    vm.updateRequest(updated);
                                  },
                                  keyboardType: TextInputType.text,
                                  isMonospaced: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Enter room button
                          SharedPrimaryButton(
                            text: 'Enter Room',
                            trailingIcon: Icons.login_outlined,
                            onPressed: () => vm.enterRoom(0),
                            isLoading: data.lobbyState == PageState.loading,
                          ),

                          const SizedBox(height: 24),

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
        );
      });

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

  Widget _buildPoweredBy() => Text(
        'POWERED BY Agora',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.slate600, // slate-600
          letterSpacing: 1.5,
        ),
        textAlign: TextAlign.center,
      );
}
