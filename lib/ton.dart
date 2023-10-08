
import 'ton_platform_interface.dart';

class Ton {
  Future<String?> getPlatformVersion() {
    return TonPlatform.instance.getPlatformVersion();
  }
}
