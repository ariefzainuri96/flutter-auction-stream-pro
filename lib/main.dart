import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'cores/utils/firebase_helper.dart';
import 'generated/app_localizations.dart';
import 'cores/config/env.dart';
import 'cores/constants/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'cores/config/flavor_config.dart';
import 'cores/routers/custom_router_observer.dart';
import 'cores/routers/router.dart';
import 'cores/routers/router_constant.dart';
import 'hive/hive_helper.dart';
import 'cores/utils/navigation_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await initializeDateFormatting('in_ID', null);

      const flavor = String.fromEnvironment('ENV');

      const envFile = flavor == 'prod' ? '.env.prod' : '.env.stage';

      await dotenv.load(fileName: envFile);

      setupFlavor(flavor);

      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
          appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
          messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
          projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        ),
      );

      // if (kDebugMode) {
      //   // Android Emulator uses 10.0.2.2 to access host machine
      //   // iOS Simulator uses localhost
      //   final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';

      //   try {
      //     FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
      //     FirebaseAuth.instance.useAuthEmulator(host, 9099);
      //     debugPrint('🔌 Connected to Firebase Emulator at $host:5001');
      //   } catch (e) {
      //     debugPrint('⚠️ Emulator connection failed: $e');
      //   }
      // }

      await signInAnonymously();

      await HiveHelper.initHive();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]).then((_) {
        runApp(
          const MainApp(
            initialRoute: Routes.splash,
          ),
        );
      });
    },
    (error, stack) {
      // TODO: handle crashlytic in here
    },
  );
}

void setupFlavor(String flavor) {
  FlavorConfig(
    flavor: convertToFlavorEnum(flavor),
    values: flavor == 'prod'
        ? FlavorValues(baseUrl: EnvProd.baseUrl)
        : FlavorValues(baseUrl: EnvStage.baseUrl),
  );
}

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) => ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: false,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: colors.backgroundDark,
            canvasColor: colors.backgroundDark,
            colorScheme: ColorScheme.dark(
              surfaceTint: colors.backgroundDark,
              surface: colors.surfaceDark,
              primary: colors.primary,
              secondary: colors.accent,
              onSurfaceVariant: Colors.white,
              onSurface: Colors.white,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('id'),
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return const Locale('en');
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
            return const Locale('en');
          },
          navigatorKey: NavigationService.navigationKey,
          navigatorObservers: [
            RouteObserver<PageRoute>(),
            CustomRouterObserver(),
          ],
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.appTitle ?? 'Prosa HI 2.0',
          initialRoute: initialRoute,
          onGenerateRoute: RouteGenerator.generateRoute,
        ),
      );
}
