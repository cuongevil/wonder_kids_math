import 'dart:io';

/// Lớp AdHelper giúp tách ID quảng cáo cho từng nền tảng
class AdHelper {
  /// App ID (bắt buộc khai báo trong AndroidManifest.xml & Info.plist)
  static String get appId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4467146889101185~1387387870';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4467146889101185~9029046505';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// App Open Ad Unit ID
  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4467146889101185/7788117027';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4467146889101185/9888694428';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
