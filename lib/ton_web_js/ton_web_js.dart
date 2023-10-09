@JS()
library ton_web_js;

import 'dart:js_interop';

import 'package:js/js.dart';

@JS('mnemonic')
class Mnemonic {
   external JSPromise generateMnemonic([int wordCount = 24, String password = '', JSArray wordList]);

   external JSPromise validateMnemonic(List<JSString> mnemonic, [String password = '']);

   external JSPromise mnemonicToSeed(List<JSString> mnemonic, [String password = '']);
}

@JS('TonWeb')
class TonWebJs {
  external static Mnemonic get mnemonic;
}