import 'package:flutter_test/flutter_test.dart';
import 'package:ton/ton.dart';
import 'package:ton/ton_platform_interface.dart';
import 'package:ton/ton_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTonPlatform with MockPlatformInterfaceMixin implements TonPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<String>?> generateRandomMnemonic({String? password}) async {
    if (password == null) {
      return List.generate(24, (index) => index.toString(), growable: false);
    }
    return [password];
  }
}

void main() {
  final TonPlatform initialPlatform = TonPlatform.instance;

  test('$MethodChannelTon is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTon>());
  });

  test('getPlatformVersion', () async {
    Ton tonPlugin = Ton();
    MockTonPlatform fakePlatform = MockTonPlatform();
    TonPlatform.instance = fakePlatform;

    expect(await tonPlugin.getPlatformVersion(), '42');
  });

  test('randomMnemonic without password', () async {
    Ton tonPlugin = Ton();
    MockTonPlatform fakePlatform = MockTonPlatform();
    TonPlatform.instance = fakePlatform;

    expect((await tonPlugin.randomMnemonic())!.length, 24);
  });

  test('randomMnemonic with password', () async {
    const String password = 'PASSWORD';

    Ton tonPlugin = Ton();
    MockTonPlatform fakePlatform = MockTonPlatform();
    TonPlatform.instance = fakePlatform;

    final mnemonic = await tonPlugin.randomMnemonic(password: password);
    expect(mnemonic!.length, 1);
    expect(mnemonic[0], password);
  });
}
