import 'dart:convert';
import 'package:pinenacl/ed25519.dart';

import '../exceptions.dart';

class TonProof {
  late int timestamp;
  late int domainLen;
  late String domainVal;
  late String payload;
  late SignatureBase signature;

  static TonProof fromMap(Map<String, dynamic> reply) {
    final proof = reply['proof'];
    if (proof == null) {
      throw TonConnectError('proof not contains in ton_proof');
    }
    final tonProof = TonProof();
    tonProof.timestamp = proof['timestamp'];
    tonProof.domainLen = proof['domain']['lengthBytes'];
    tonProof.domainVal = proof['domain']['value'];
    tonProof.payload = proof['payload'];

    final Uint8List signedMessage = base64Decode(proof['signature']);
    final SignatureBase signature =
        SignedMessage.fromList(signedMessage: signedMessage).signature;
    tonProof.signature = signature;
    return tonProof;
  }
}
