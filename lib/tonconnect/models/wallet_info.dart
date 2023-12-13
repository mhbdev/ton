import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:ton/tonconnect/models/ton_proof.dart';

import '../logger.dart';
import 'account.dart';
import 'device_info.dart';

class WalletInfo {
  // Information about user's wallet's device
  DeviceInfo? device;

  // Provider type
  String provider = 'http'; // only http supported

  // Selected account
  Account? account;

  // Response for ton_proof item request
  TonProof? tonProof;

  WalletInfo();

  @override
  String toString() {
    return '<WalletInfo ${account.toString()}>';
  }

  bool checkProof({String? src}) {
    if (tonProof == null) {
      return false;
    }

    var wcWhash = account!.address.split(':')[2];
    var wc = int.parse(wcWhash[0]);
    var whash = wcWhash[1];

    Uint8List message = Uint8List(0);
    message.addAll(utf8.encode('ton-proof-item-v2/'));
    message.addAll(_intToBytes(wc, Endian.little));
    message.addAll(hex.decode(whash));
    message.addAll(_intToBytes(tonProof!.domainLen, Endian.little));
    message.addAll(utf8.encode(tonProof!.domainVal));
    message.addAll(_intToBytes(tonProof!.timestamp, Endian.little));
    if (src != null) {
      message.addAll(utf8.encode(src));
    } else {
      message.addAll(utf8.encode(tonProof!.payload));
    }

    var signatureMessage = Uint8List(0);
    signatureMessage.addAll(hex.decode('ffff'));
    signatureMessage.addAll(utf8.encode('ton-connect'));
    signatureMessage.addAll(sha256.convert(message).bytes);

    try {
      var verifyKey =
      VerifyKey(Uint8List.fromList(utf8.encode(account!.publicKey)));
      verifyKey.verify(
          message: Uint8List.fromList(sha256.convert(signatureMessage).bytes),
          signature: tonProof!.signature);
      logger.d('PROOF IS OK');
      return true;
    } catch (e) {
      logger.e('PROOF ERROR');
      return false;
    }
  }

  Uint8List _intToBytes(int value, Endian endian) {
    Uint8List bytes = Uint8List(4);
    ByteData byteData = ByteData.view(bytes.buffer);
    byteData.setInt32(0, value, endian);
    return bytes;
  }
}