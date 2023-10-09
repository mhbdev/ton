import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ton/ton.dart';
import 'package:ton/ton_platform_interface.dart';
import 'package:ton/ton_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTonPlatform with MockPlatformInterfaceMixin implements TonPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<String>?> generateRandomMnemonic({String? password, int wordsCount = 24}) async {
    if (password == null) {
      return List.generate(wordsCount, (index) => index.toString(), growable: false);
    }
    return [password];
  }

  @override
  Future<Uint8List?> toSeed(List<String> mnemonic) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isMnemonicValid(List<String> mnemonic, [String? password]) async {
    if(mnemonic.length == 24 || mnemonic.length == 12) {
      return true;
    }
    return false;
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

  test('randomMnemonic with 12 wordsCount', () async {
    const wordsCount = 12;

    Ton tonPlugin = Ton();
    MockTonPlatform fakePlatform = MockTonPlatform();
    TonPlatform.instance = fakePlatform;

    final mnemonic = await tonPlugin.randomMnemonic(wordsCount: wordsCount);
    expect(mnemonic!.length, wordsCount);
  });

  test('check if mnemonic is valid', () async {
    Ton tonPlugin = Ton();
    MockTonPlatform fakePlatform = MockTonPlatform();
    TonPlatform.instance = fakePlatform;

    final mnemonic = await tonPlugin.randomMnemonic();
    expect(await tonPlugin.isMnemonicValid(mnemonic ?? []), true);
  });
}
