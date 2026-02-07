import 'package:flutter/material.dart';
import '../../../cores/base/base_provider_view.dart';
import '../../../cores/constants/colors.dart';
import '../../../cores/constants/image_paths.dart';
import '../providers/splash_provider.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) => BaseProviderView(
        provider: splashProvider,
        useSafeArea: false,
        builder: _buildScreen,
      );

  Widget _buildScreen(
    BuildContext context,
    String data,
    SplashNotifier vm,
  ) =>
      Container(
          width: double.infinity,
          height: double.infinity,
          color: colors.primary,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  images.splashImg,
                  height: 120,
                  width: 120,
                ),
              ),
            ],
          ),
        );
}
