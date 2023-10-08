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
}
