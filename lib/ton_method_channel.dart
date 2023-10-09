import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ton_platform_interface.dart';

/// An implementation of [TonPlatform] that uses method channels.
class MethodChannelTon extends TonPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ton');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<String>?> generateRandomMnemonic({String? password, int wordsCount = 24}) async {
    final mnemonic = await methodChannel.invokeListMethod<String>('generateRandomMnemonic', {
      'password': password,
      'wordCount': wordsCount,
    });
    return mnemonic;
  }

  @override
  Future<Uint8List?> toSeed(List<String> mnemonic) async {
    final seed = await methodChannel.invokeMethod<Uint8List>('toSeed', {
      'mnemonic': mnemonic,
    });

    return seed;
  }
  
  @override
  Future<bool> isMnemonicValid(List<String> mnemonic, [String? password]) async {
    final isValid = await methodChannel.invokeMethod<bool>('isMnemonicValid', {
      'mnemonic': mnemonic,
      'password': password,
    });

    return isValid ?? false;
  }
}
