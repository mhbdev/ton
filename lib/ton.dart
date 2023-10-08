import 'ton_platform_interface.dart';

class Ton {
  Future<String?> getPlatformVersion() {
    return TonPlatform.instance.getPlatformVersion();
  }

  Future<List<String>?> randomMnemonic({String? password, int wordsCount = 24}) {
    return TonPlatform.instance.generateRandomMnemonic(
      password: password,
      wordsCount: wordsCount,
    );
  }
}
