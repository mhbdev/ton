import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:pinenacl/x25519.dart'
    show Box, PrivateKey, EncryptedMessage, PublicKey;
import 'package:pinenacl/api.dart';

class SessionCrypto {
  late final PrivateKey privateKey;
  late final String sessionId;

  SessionCrypto({String? pk}) {
    privateKey = pk != null ? PrivateKey.decode(pk) : PrivateKey.generate();
    sessionId = hex.encode(privateKey.publicKey);
  }

  String encrypt(String message, String stringReceiverPubKey) {
    final List<int> hexReceiverPubKey = hex.decode(stringReceiverPubKey);
    final Uint8List uintReceiverPubKey = Uint8List.fromList(hexReceiverPubKey);
    final receiverPk = PublicKey(uintReceiverPubKey);

    final box = Box(myPrivateKey: privateKey, theirPublicKey: receiverPk);
    final encrypted = box.encrypt(Uint8List.fromList(utf8.encode(message)));

    return base64Encode(encrypted);
  }

  String decrypt(String message, String stringSenderPubKey) {
    final Uint8List msg = base64.decode(message);

    final List<int> hexSenderPubKey = hex.decode(stringSenderPubKey);
    final Uint8List uintSenderPubKey = Uint8List.fromList(hexSenderPubKey);
    final senderPk = PublicKey(uintSenderPubKey);

    final box = Box(myPrivateKey: privateKey, theirPublicKey: senderPk);
    final decrypted = box.decrypt(EncryptedMessage.fromList(msg));

    return utf8.decode(decrypted);
  }
}