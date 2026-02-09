import 'package:flutter/material.dart';
import '../../features/auction_list/views/auction_list_view.dart';
import '../../features/auction_stage/views/auction_stage_view.dart';
import '../../features/create_auction/views/create_auction_view.dart';
import '../../features/lobby/views/lobby_view.dart';
import '../../features/login/views/login_view.dart';
import '../../features/splash/views/splash_view.dart';
import 'router_constant.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const LoginView(),
        );
      case Routes.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const SplashView(),
        );
      case Routes.lobby:
        final data = args as int;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => LobbyView(hostId: data),
        );
      case Routes.auctionList:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const AuctionListView(),
        );
      case Routes.createAuction:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const CreateAuctionView(),
        );
      case Routes.auctionStage:
        final data = args as AuctionStageViewData;

        return MaterialPageRoute(
          settings: settings,
          builder: (context) => AuctionStageView(args: data),
        );
      // case Routes.profileNakes:
      //   final data = args as ProfileNakesArgsModel;

      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => ProfileNakesView(args: data),
      //   );
      default:
        return _notFoundPage();
    }
  }

  static Route<dynamic> _notFoundPage() => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Error!')),
          body:
              const Center(child: Text('Page not found!, add your page here')),
        ),
      );
}
