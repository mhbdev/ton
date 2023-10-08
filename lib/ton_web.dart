// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'dart:js' as js;
import 'dart:js_util';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:ton/ton_web_js/ton_web_js.dart';
import 'ton_platform_interface.dart';

final jsContext = js.context;

/// A web implementation of the TonPlatform of the Ton plugin.
class TonWeb extends TonPlatform {
  /// Constructs a TonWeb
  TonWeb();

  static void registerWith(Registrar registrar) {
    TonPlatform.instance = TonWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }

  @override
  Future<List<String>?> generateRandomMnemonic({String? password, int wordsCount = 24}) async {
    return (await promiseToFuture((password != null
            ? TonWebJs.mnemonic.generateMnemonic(wordsCount, password)
            : TonWebJs.mnemonic.generateMnemonic())) as List<dynamic>)
        .map((e) => e.toString())
        .toList();
  }
}
