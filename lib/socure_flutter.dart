
import 'socure_flutter_platform_interface.dart';

class SocureFlutter {
  Future<String?> getPlatformVersion() {
    return SocureFlutterPlatform.instance.getPlatformVersion();
  }
}
