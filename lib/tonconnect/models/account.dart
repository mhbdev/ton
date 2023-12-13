import 'package:ton/tonconnect/models/chain.dart';

import '../exceptions.dart';

class Account {
  // User's address in "hex" format: "<wc>:<hex>"
  late String address;

  // User's selected chain
  late Chain chain;

  // Base64 (not url safe) encoded wallet contract state_init.
  // Can be used to get user's public key from the state_init if the wallet contract doesn't support corresponding method
  late String walletStateInit;

  // Hex string without 0x prefix
  late String publicKey;

  @override
  String toString() => '<Account "$address">';

  static Account fromMap(Map<String, dynamic> tonAddr) {
    if (!tonAddr.containsKey('address')) {
      throw TonConnectError('address not contains in ton_addr');
    }

    final account = Account();
    account.address = tonAddr['address'];
    account.chain = Chain.getChainByValue(int.tryParse(tonAddr['network'].toString()) ?? -239);
    account.walletStateInit = tonAddr['walletStateInit'];
    account.publicKey = tonAddr.containsKey('publicKey') ? tonAddr['publicKey'] : null;
    return account;
  }
}
