import 'exceptions.dart';
import 'logger.dart';
import 'models/transaction.dart';
import 'models/wallet_app.dart';
import 'models/wallet_info.dart';
import 'parsers/connect_event.dart';
import 'parsers/send_transaction.dart';
import 'provider/bridge_provider.dart';
import 'storage/default_storage.dart';
import 'storage/storage_interface.dart';
import 'types.dart';
import 'wallet_list_manager.dart';

class TonConnect {
  WalletsListManager _walletsList = WalletsListManager();

  BridgeProvider? provider;
  final String _manifestUrl;

  late IStorage storage;
  WalletInfo? wallet;

  List<void Function(dynamic value)> _statusChangeSubscriptions = [];
  List<void Function(dynamic value)> _statusChangeErrorSubscriptions = [];

  /// Shows if the wallet is connected right now.
  bool get connected => wallet != null;

  /// Current connected account or None if no account is connected.
  dynamic get account => connected ? wallet!.account : null;

  TonConnect(this._manifestUrl,
      {IStorage? customStorage,
        String? walletsListSource,
        int? walletsListCacheTtl}) {
    storage = customStorage ?? DefaultStorage();

    _walletsList = WalletsListManager(
        walletsListSource: walletsListSource, cacheTtl: walletsListCacheTtl);
    provider = null;
    wallet = null;
    _statusChangeSubscriptions = [];
    _statusChangeErrorSubscriptions = [];
  }

  /// Return available wallets list.
  Future<List<WalletApp>> getWallets() async {
    return await _walletsList.getWallets();
  }

  /// Allows to subscribe to connection status changes and handle connection errors.
  Function onStatusChange(void Function(dynamic value) callback,
      [void Function(dynamic value)? errorsHandler]) {
    _statusChangeSubscriptions.add(callback);
    if (errorsHandler != null) {
      _statusChangeErrorSubscriptions.add(errorsHandler);
    }

    unsubscribe() {
      if (_statusChangeSubscriptions.contains(callback)) {
        _statusChangeSubscriptions.remove(callback);
      }
      if (errorsHandler != null &&
          _statusChangeErrorSubscriptions.contains(errorsHandler)) {
        _statusChangeErrorSubscriptions.remove(errorsHandler);
      }
    }

    return unsubscribe;
  }

  /// Generates universal link for an external wallet and subscribes to the wallet's bridge,
  /// or sends connect request to the injected wallet.
  Future<String> connect(WalletApp wallet, [dynamic request]) async {
    if (connected) {
      throw WalletAlreadyConnectedError(null);
    }

    if (provider != null) {
      provider!.closeConnection();
    }

    provider = _createProvider(wallet);

    return await provider!.connect(_createConnectRequest(request));
  }

  /// Try to restore existing session and reconnect to the corresponding wallet.
  /// Call it immediately when your app is loaded.
  Future<bool> restoreConnection() async {
    try {
      provider = BridgeProvider(storage);
    } catch (e) {
      await storage.removeItem(key: IStorage.keyConnection);
      provider = null;
    }

    if (provider == null) {
      return false;
    }

    provider!.listen(_walletEventsListener);
    return await provider!.restoreConnection();
  }

  /// Asks connected wallet to sign and send the transaction.
  Future<dynamic> sendTransaction(Transaction transaction) async {
    if (!connected) {
      throw WalletNotConnectedError(null);
    }

    Json options = {
      'required_messages_number': transaction.messages.length
    };
    _checkSendTransactionSupport(wallet!.device!.features, options);

    Json request = {
      'valid_until': transaction.validUntil,
      'from': transaction.from ?? wallet!.account!.address,
      'network': transaction.network?.value ?? wallet!.account!.chain.value,
      'messages': transaction.messages.map((e) => e.toMap()).toList(),
    };

    Json response = await provider!
        .sendRequest(SendTransactionParser().convertToRpcRequest(request));

    if (SendTransactionParser().isError(response)) {
      return SendTransactionParser().parseAndThrowError(response);
    }

    return SendTransactionParser().convertFromRpcResponse(response);
  }

  /// Disconnect from wallet and drop current session.
  Future<void> disconnect() async {
    if (!connected) {
      throw WalletNotConnectedError(null);
    }

    await provider!.disconnect();
    _onWalletDisconnected();
  }

  /// Pause bridge HTTP connection. Might be helpful, if you use SDK on backend and want to save server resources.
  void pauseConnection() {
    provider?.pause();
  }

  /// Unpause bridge HTTP connection if it is paused.
  Future<void> unpauseConnection() async {
    await provider?.unpause();
  }

  void _checkSendTransactionSupport(
      dynamic features, Json options) {
    bool supportsDeprecatedSendTransactionFeature =
    features.contains('SendTransaction');
    dynamic sendTransactionFeature;
    for (var feature in features) {
      if (feature is Json &&
          feature['name'] == 'SendTransaction') {
        sendTransactionFeature = feature;
        break;
      }
    }

    if (!supportsDeprecatedSendTransactionFeature &&
        sendTransactionFeature == null) {
      throw WalletNotSupportFeatureError(
          "Wallet doesn't support SendTransaction feature.");
    }

    if (sendTransactionFeature != null) {
      int? maxMessages = sendTransactionFeature['maxMessages'];
      int? requiredMessages = options['required_messages_number'];
      if (maxMessages != null &&
          requiredMessages != null &&
          maxMessages < requiredMessages) {
        throw WalletNotSupportFeatureError(
            'Wallet is not able to handle such SendTransaction request. Max support messages number is $maxMessages, but $requiredMessages is required.');
      }
    } else {
      logger.w(
          "Connected wallet didn't provide information about max allowed messages in the SendTransaction request. Request may be rejected by the wallet.");
    }
  }

  BridgeProvider _createProvider(WalletApp wallet) {
    BridgeProvider provider = BridgeProvider(storage, wallet: wallet);
    provider.listen(_walletEventsListener);
    return provider;
  }

  void _walletEventsListener(Json data) {
    if (data['event'] == 'connect') {
      _onWalletConnected(data['payload']);
    } else if (data['event'] == 'connect_error') {
      _onWalletConnectError(data['payload']);
    } else if (data['event'] == 'disconnect') {
      _onWalletDisconnected();
    }
  }

  void _onWalletConnected(dynamic payload) {
    wallet = ConnectEventParser.parseResponse(payload);
    for (var listener in _statusChangeSubscriptions) {
      listener(wallet);
    }
  }

  void _onWalletConnectError(dynamic payload) {
    logger.d('connect error $payload');
    dynamic error = ConnectEventParser.parseError(payload);
    for (var listener in _statusChangeErrorSubscriptions) {
      listener(error);
    }

    if (error is ManifestNotFoundError || error is ManifestContentError) {
      logger.e(error);
      throw error;
    }
  }

  void _onWalletDisconnected() {
    wallet = null;
    for (var listener in _statusChangeSubscriptions) {
      listener(null);
    }
  }

  Json _createConnectRequest(dynamic request) {
    List<Json> items = [
      {'name': 'ton_addr'}
    ];

    if (request is Json && request.containsKey('ton_proof')) {
      items.add({
        'name': 'ton_proof',
        'payload': request['ton_proof'],
      });
    }

    return {
      'manifestUrl': _manifestUrl,
      'items': items,
    };
  }
}