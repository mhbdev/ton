import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ton_method_channel.dart';

abstract class TonPlatform extends PlatformInterface {
  /// Constructs a TonPlatform.
  TonPlatform() : super(token: _token);

  static final Object _token = Object();

  static TonPlatform _instance = MethodChannelTon();

  /// The default instance of [TonPlatform] to use.
  ///
  /// Defaults to [MethodChannelTon].
  static TonPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TonPlatform] when
  /// they register themselves.
  static set instance(TonPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
