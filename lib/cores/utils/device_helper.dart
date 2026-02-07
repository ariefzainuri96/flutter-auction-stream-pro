
class DeviceHelper {
  // Singleton boilerplate
  DeviceHelper._();
  static final DeviceHelper instance = DeviceHelper._();

  int _signupProcessStart = 0;
  int _numberInputProcessStart = 0;

  int _emulatorFlag = -1;

  /// Call this when user starts the signup process
  void startSignUpProcess() {
    _signupProcessStart = DateTime.now().millisecondsSinceEpoch;
    _numberInputProcessStart = 0;
  }

  /// Call this when user starts inputting their number
  void startSignUpNumberInput() {
    if (_numberInputProcessStart == 0) {
      _numberInputProcessStart = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// Returns how many ms since signup process started
  int getSignupDuration() {
    if (_signupProcessStart == 0) return 0;
    return DateTime.now().millisecondsSinceEpoch - _signupProcessStart;
  }

  /// Returns how many ms since number input started
  int getNumberInputDuration() {
    if (_numberInputProcessStart == 0) return 0;
    return DateTime.now().millisecondsSinceEpoch - _numberInputProcessStart;
  }

  /// Checks if emulator (async, because device_info_plus is async)
  // Future<int> isEmulator() async {
  //   if (_emulatorFlag == -1) {
  //     _emulatorFlag = await _checkEmulatorText() ? 1 : 0;
  //   }
  //   return _emulatorFlag;
  // }

  /// Returns a random 'flag' string as in original code
  // Future<String> getEmulatorFlag() async {
  //   int flag = await isEmulator();
  //   int randNum = Random().nextInt(499999 - 50000) + 50000;
  //   return ((randNum * 2) + flag).toString();
  // }

  /// Emulator heuristics (Android/iOS only)
  // Future<bool> _checkEmulatorText() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo android = await deviceInfo.androidInfo;
  //     // Check product name and fingerprint
  //     if (android.product == 'sdk_gphone64_x86_64') return true;
  //     final fingerprint =
  //         '${android.fingerprint}${android.model}${android.board}'
  //             .toLowerCase();
  //     if (fingerprint
  //             .contains('google/sdk_gphone64_x86_64/emulator64_x86_64_arm64') ||
  //         fingerprint.contains('sdk_gphone64_x86') ||
  //         fingerprint.contains('goldfish_x86_64') ||
  //         fingerprint.contains('emulator') ||
  //         fingerprint.contains('vbox') ||
  //         fingerprint.contains('android sdk built for x86')) {
  //       return true;
  //     }
  //     return !android.isPhysicalDevice;
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo ios = await deviceInfo.iosInfo;
  //     // iOS Simulator check (common hack)
  //     if (!ios.isPhysicalDevice) return true;
  //     // Add more checks as needed
  //     return false;
  //   }
  //   // Default to not emulator for other platforms
  //   return false;
  // }
}
