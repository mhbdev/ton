import 'package:flutter/material.dart';
import 'package:ton/tonconnect/models/account.dart';
import 'package:ton/tonconnect/models/wallet_app.dart';
import 'package:ton/tonconnect/wallet_list_manager.dart';
import 'package:tonutils/dataformat.dart';

import '../../tonconnect/tonconnect.dart';

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

  Future<bool> restoreConnection() => _connector.restoreConnection();

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
    return await _connector.connect(walletApp);
  }
}
