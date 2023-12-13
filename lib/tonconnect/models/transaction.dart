import 'package:ton/tonconnect/types.dart';
import 'package:tonutils/dataformat.dart';

import 'chain.dart';

class Transaction {
  /// Sending transaction deadline in unix epoch seconds.
  final int validUntil;

  /// The network (mainnet or testnet) where DApp intends to send the transaction. If not set, the transaction is sent to the network currently set in the wallet, but this is not safe and DApp should always strive to set the network. If the network parameter is set, but the wallet has a different network set, the wallet should show an alert and DO NOT ALLOW TO SEND this transaction.
  final Chain? network;

  /// The sender address in '<wc>:<hex>' format from which DApp intends to send the transaction. Current account.address by default.
  final String? from;

  /// Messages to send: min is 1, max is 4.
  final List<OutMessage> messages;

  Transaction({required this.validUntil, this.network, this.from, this.messages = const []});
}

class OutMessage {
  /// Receiver's address.
  final InternalAddress address;

  /// Amount to send in nanoTon.
  final BigInt amount;

  /// Contract specific data to add to the transaction.
  final String? stateInit;

  /// Contract specific data to add to the transaction.
  final String? payload;

  OutMessage({required this.address, required this.amount, this.stateInit, this.payload});

  Json toMap() {
    return {
      'amount': amount.toString(),
      'address': address.toRawString(),
      if (stateInit != null) 'stateInit': stateInit,
      if (payload != null) 'payload': payload,
    };
  }
}
