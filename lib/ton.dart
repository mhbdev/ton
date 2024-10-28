import 'package:flutter/services.dart';
import 'ton_platform_interface.dart';

export 'package:tonutils/tonutils.dart';

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

  Future<Uint8List?> toSeed(List<String> mnemonic) {
    return TonPlatform.instance.toSeed(mnemonic);
  }

  Future<bool> isMnemonicValid(List<String> mnemonic, [String? password]) {
    return TonPlatform.instance.isMnemonicValid(mnemonic, password);
  }
}
