import 'dart:async';
import 'dart:convert';

import 'package:ton/tonconnect/types.dart';

import '../crypto/session_crypto.dart';
import '../exceptions.dart';
import '../logger.dart';
import '../models/wallet_app.dart';
import '../storage/storage_interface.dart';
import 'base_provider.dart';
import 'bridge_gateway.dart';
import 'bridge_session.dart';

class BridgeProvider extends BaseProvider {
  static const int disconnectTimeout = 600;
  static const String standartUniversalUrl = 'tc://';

  late IStorage _storage;
  WalletApp? _wallet;

  late BridgeSession _session;
  BridgeGateway? _gateway;
  late Map<String, Completer<Json>> _pendingRequests;
  late List<dynamic> _listeners;

  BridgeProvider(IStorage storage, {WalletApp? wallet}) {
    _storage = storage;
    _wallet = wallet;

    _session = BridgeSession();
    _gateway = null;
    _pendingRequests = {};
    _listeners = [];
  }

  Future<String> connect(Json request) async {
    _closeGateways();
    final sessionCrypto = SessionCrypto();

    String bridgeUrl = _wallet?.bridgeUrl ?? '';
    String universalUrl = _wallet?.universalUrl ?? BridgeProvider.standartUniversalUrl;

    _gateway = BridgeGateway(
      _storage,
      bridgeUrl,
      sessionCrypto.sessionId,
      _gatewayListener,
      _gatewayErrorsListener,
    );

    await _gateway!.registerSession();

    _session.sessionCrypto = sessionCrypto;
    _session.bridgeUrl = bridgeUrl;

    return _generateUniversalUrl(universalUrl, request);
  }

  @override
  Future<bool> restoreConnection() async {
    _closeGateways();

    var connection = await _storage.getItem(key: IStorage.keyConnection);
    if (connection == null) {
      return false;
    }
    final decodeConnection = jsonDecode(connection) as Json;

    if (!decodeConnection.containsKey('session')) {
      return false;
    }
    _session = BridgeSession(stored: decodeConnection['session']);

    _gateway = BridgeGateway(
      _storage,
      _session.bridgeUrl!,
      _session.sessionCrypto.sessionId,
      _gatewayListener,
      _gatewayErrorsListener,
    );

    await _gateway!.registerSession();

    for (final listener in _listeners) {
      listener(decodeConnection['connect_event']);
    }

    return true;
  }

  @override
  void closeConnection() {
    _closeGateways();
    _session = BridgeSession();
    _gateway = null;
    _pendingRequests = {};
    _listeners = [];
  }

  @override
  Future<void> disconnect() async {
    final completer = Completer<void>();

    try {
      await Future.any([
        sendRequest({'method': 'disconnect', 'params': []}),
        Future.delayed(const Duration(seconds: disconnectTimeout)),
      ]);
    } catch (error, stackTrace) {
      logger.e('Provider disconnect', error: error, stackTrace: stackTrace);
    } finally {
      if (!completer.isCompleted) {
        await _removeSession();
        completer.complete();
      }
    }

    return completer.future;
  }

  void pause() {
    _gateway?.pause();
  }

  Future<void> unpause() async {
    await _gateway?.unpause();
  }

  @override
  Future<Json> sendRequest(dynamic request) async {
    final String decryptMessage = _session.sessionCrypto
        .decrypt("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", "ccc281db258b065adc008a9c553cfaf7b139088902e44a9f7c844e9eb6c37f7a");
    print(decryptMessage);
    if (_gateway == null || _session.walletPublicKey == null) {
      throw TonConnectError('Trying to send bridge request without session.');
    }
    final keyConnection = await _storage.getItem(key: IStorage.keyConnection, defaultValue: '{}');
    var connection = jsonDecode(keyConnection!) as Json;
    var id = connection['next_rpc_request_id'] != null
        ? connection['next_rpc_request_id'].toString()
        : '0';

    connection['next_rpc_request_id'] = (int.parse(id) + 1).toString();
    await _storage.setItem(key: IStorage.keyConnection, value: jsonEncode(connection));

    request['id'] = id;
    logger.d('Provider send http-bridge request: $request');

    final encodedRequest = _session.sessionCrypto.encrypt(
      jsonEncode(request),
      _session.walletPublicKey!,
    );

    await _gateway!.send(encodedRequest, _session.walletPublicKey!, request['method']);

    final completer = Completer<Json>();
    _pendingRequests[id] = completer;
    return _pendingRequests;
  }

  @override
  void listen(Function eventsCallback) {
    _listeners.add(eventsCallback);
  }

  Future<void> _gatewayListener(Json bridgeIncomingMessage) async {
    final String decryptMessage = _session.sessionCrypto
        .decrypt(bridgeIncomingMessage['message'], bridgeIncomingMessage['from']);
    final walletMessage = jsonDecode(decryptMessage) as Json;

    logger.d('Wallet message received: $walletMessage');

    if (!walletMessage.containsKey('event')) {
      if (walletMessage.containsKey('id')) {
        final id = walletMessage['id'].toString();
        if (!_pendingRequests.containsKey(id)) {
          logger.d("Response id $id doesn't match any request's id");
          return;
        }

        _pendingRequests[id]!.complete(walletMessage);
        _pendingRequests.remove(id);
      }
    }

    if (walletMessage.containsKey('id')) {
      final id = int.parse(walletMessage['id'].toString());
      final keyConnection = await _storage.getItem(key: IStorage.keyConnection, defaultValue: '{}');
      var connection = jsonDecode(keyConnection!) as Json;
      final lastId =
          connection.containsKey('last_wallet_event_id') ? connection['last_wallet_event_id'] : 0;

      if (lastId != null && id <= lastId) {
        logger.e(
            'Received event id (=$id) must be greater than stored last wallet event id (=$lastId)');
        return;
      }

      if (walletMessage.containsKey('event') && walletMessage['event'] != 'connect') {
        connection['last_wallet_event_id'] = id;
        await _storage.setItem(key: IStorage.keyConnection, value: jsonEncode(connection));
      }
    }

    final listeners = [..._listeners];

    if (walletMessage['event'] == 'connect') {
      await _updateSession(walletMessage, bridgeIncomingMessage['from']);
    } else if (walletMessage['event'] == 'disconnect') {
      await _removeSession();
    }

    for (final listener in listeners) {
      listener(walletMessage);
    }
  }

  void _gatewayErrorsListener() {
    throw TonConnectError('Bridge error');
  }

  Future<void> _updateSession(Json connectEvent, String walletPublicKey) async {
    _session.walletPublicKey = walletPublicKey;

    final connection = {
      'type': 'http',
      'session': _session.getMap(),
      'last_wallet_event_id': connectEvent.containsKey('id') ? connectEvent['id'] : null,
      'connect_event': connectEvent,
      'next_rpc_request_id': 0,
    };

    await _storage.setItem(key: IStorage.keyConnection, value: jsonEncode(connection));
  }

  Future<void> _removeSession() async {
    if (_gateway != null) {
      closeConnection();
      await _storage.removeItem(key: IStorage.keyConnection);
      await _storage.removeItem(key: IStorage.keyLastEventId);
    }
  }

  String _generateUniversalUrl(String universalUrl, Json request) {
    const version = 2;
    final sessionId = _session.sessionCrypto.sessionId;
    final requestSafe = Uri.encodeComponent(jsonEncode(request));

    final url = '$universalUrl?v=$version&id=$sessionId&r=$requestSafe';

    return url;
  }

  void _closeGateways() {
    _gateway?.close();
  }
}
