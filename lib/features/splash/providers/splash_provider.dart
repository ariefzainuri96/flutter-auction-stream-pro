import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cores/config/flavor_config.dart';
import '../../../cores/routers/router_constant.dart';
import '../../../cores/utils/navigation_service.dart';
import '../../../cores/utils/string_extension.dart';

final splashProvider = NotifierProvider.autoDispose<SplashNotifier, String>(
  SplashNotifier.new,
);

class SplashNotifier extends Notifier<String> {
  @override
  String build() {
    Future.microtask(_checkUserExpiredProcess);

    return '';
  }

  Future<void> _checkUserExpiredProcess() async {
    await Future.delayed(const Duration(seconds: 1));

    final role = FlavorConfig.instance?.values.token;

    if (role.isNotNullOrEmpty) {
      // TODO: route to desired page based on role
    } else {
      NavigationService.pushNamedAndRemoveAll(Routes.login);
    }
  }
}
