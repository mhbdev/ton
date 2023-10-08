import 'package:flutter_test/flutter_test.dart';
import 'package:ton/ton.dart';
import 'package:ton/ton_platform_interface.dart';
import 'package:ton/ton_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTonPlatform
    with MockPlatformInterfaceMixin
    implements TonPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
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
}
