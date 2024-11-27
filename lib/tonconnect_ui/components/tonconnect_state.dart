import 'package:flutter/material.dart';
import 'package:ton/tonconnect/models/account.dart';
import 'package:ton/tonconnect/models/transaction.dart';
import 'package:ton/tonconnect/models/wallet_app.dart';
import 'package:ton/tonconnect/provider/bridge_provider.dart';
import 'package:ton/tonconnect/tonconnect.dart';
import 'package:ton/tonconnect/wallet_list_manager.dart';

class TonConnectState extends ChangeNotifier {
  final BuildContext _context;
  final String _manifestUrl;
  late final TonConnect _connector;
  dynamic _status;

  TonConnectState({
    required BuildContext context,
    required String manifestUrl,
  })  : _context = context,
        _manifestUrl = manifestUrl {
    _connector = TonConnect(manifestUrl);
    _connector.onStatusChange((status) {
      _status = status;
      notifyListeners();
    });
  }

  dynamic get status => _status;

  bool get connected => _connector.connected;

  Function onStatusChange(void Function(dynamic value) callback,
      [void Function(dynamic value)? errorsHandler]) {
    return _connector.onStatusChange(callback, errorsHandler);
  }

  Future<bool> restoreConnection() => _connector.restoreConnection();

  Future<dynamic> sendTransaction(Transaction transaction) {
    return _connector.sendTransaction(transaction);
  }

  BridgeProvider? get provider => _connector.provider;

  Future<void> disconnect() => _connector.disconnect();

  Account? getConnectedWallet() => _connector.wallet?.account;

  Future<List<WalletApp>> getWallets() async => await _connector.getWallets();

  Future<String> connect({WalletApp? walletApp, dynamic request}) async {
    try {
      final wallets = await _connector.getWallets();
      walletApp ??= (wallets.isNotEmpty ? wallets.first : fallbackWalletsList.first);
    } catch(e) {
      walletApp ??= fallbackWalletsList.first;
    }
    return await _connector.connect(walletApp, request);
  }
}
