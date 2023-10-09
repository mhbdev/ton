import 'dart:typed_data';

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

  /// Generate a random mnemonic
  /// [password] will be used if it is passed to this method
  /// You can also pass [wordsCount] to specify number of words in your password list
  Future<List<String>?> generateRandomMnemonic({
    String? password,
    int wordsCount = 24,
  }) {
    throw UnimplementedError('generateRandomMnemonic() has not been implemented.');
  }

  /// Converts [mnemonic] to Seed
  Future<Uint8List?> toSeed(List<String> mnemonic) {
    throw UnimplementedError('toSeed() has not been implemented.');
  }

  /// Check if the given mnemonic is valid or not
  Future<bool> isMnemonicValid(List<String> mnemonic, [String? password]) {
    throw UnimplementedError('isMnemonicValid() has not been implemented.');
  }
}
