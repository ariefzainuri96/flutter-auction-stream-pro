import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../config/flavor_config.dart';

const String generateAgoraTokenUrl =
    'https://generateagoratoken-pkqdrvmzdq-uc.a.run.app';

Future<void> signInAnonymously() async {
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    debugPrint('Signed in with temporary ID: ${userCredential.user?.uid}');
  } catch (e) {
    debugPrint('Sign in failed: $e');
  }
}

Future<(String, String)> generateToken({
  required String channelName,
  required int uid,
  required String role, // 'publisher' or 'subscriber'
}) async {
  try {
    HttpsCallable callable;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('⚠️ User not logged in. Signing in anonymously...');
      UserCredential cred = await FirebaseAuth.instance.signInAnonymously();
      user = cred.user;
    }

    debugPrint('✅ User authenticated: ${user?.uid}');

    callable = FirebaseFunctions.instance.httpsCallableFromUri(
      Uri.parse(generateAgoraTokenUrl),
    );

    if (kDebugMode) {
      callable = FirebaseFunctions.instance.httpsCallable(
        'generateAgoraToken',
      );
    } else {
      callable = FirebaseFunctions.instance.httpsCallableFromUri(
        Uri.parse(generateAgoraTokenUrl),
      );
    }

    final result = await callable.call({
      'channelName': channelName,
      'uid': uid,
      'role': role,
      'env': FlavorConfig.instance?.flavor == Flavor.prod ? 'prod' : 'dev',
    });

    final String rtcToken = result.data['rtcToken'];
    final String rtmToken = result.data['rtmToken'];
    debugPrint('✅ RTC Token generated: $rtcToken');
    debugPrint('✅ RTM Token generated: $rtmToken');
    return (rtcToken, rtmToken);
  } catch (e) {
    debugPrint('❌ Error generating token: $e');
    if (e is FirebaseFunctionsException) {
      debugPrint('Code: ${e.code}, Message: ${e.message}');
    }
    rethrow;
  }
}
