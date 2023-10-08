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
    final mnemonic = await methodChannel.invokeMethod<List<Object?>>('generateRandomMnemonic', {
      'password': password,
      'wordCount': wordsCount,
    });
    return mnemonic?.map((e) => e.toString()).toList();
  }
}
