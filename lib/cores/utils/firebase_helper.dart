import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../config/flavor_config.dart';

Future<void> signInAnonymously() async {
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    debugPrint('Signed in with temporary ID: ${userCredential.user?.uid}');
  } catch (e) {
    debugPrint('Sign in failed: $e');
  }
}

Future<String> generateToken({
  required String channelName,
  required int uid,
  required String role, // 'publisher' or 'subscriber'
}) async {
  try {
    // 1. Ensure User is Authenticated (Anonymous is fine)
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('⚠️ User not logged in. Signing in anonymously...');
      UserCredential cred = await FirebaseAuth.instance.signInAnonymously();
      user = cred.user;
    }

    // 2. Get the Functions Instance
    // IMPORTANT: If you deployed to Jakarta, add: region: 'asia-southeast2'
    final functions = FirebaseFunctions.instance;

    // 3. Define the Callable
    final callable = functions.httpsCallable('generateAgoraToken');

    // 4. Call the function
    // Note: We don't need to wrap in 'data'. The SDK does it automatically.
    final result = await callable.call({
      'channelName': channelName,
      'uid': uid,
      'role': role,
      'env': FlavorConfig.instance?.flavor == Flavor.prod
          ? 'prod'
          : 'dev', // Send env flag dynamically
    });

    // 5. Extract the token
    final String token = result.data['token'];
    debugPrint('✅ Token generated: $token');
    return token;
  } catch (e) {
    debugPrint('❌ Error generating token: $e');
    if (e is FirebaseFunctionsException) {
      debugPrint('Code: ${e.code}, Message: ${e.message}');
    }
    rethrow;
  }
}
