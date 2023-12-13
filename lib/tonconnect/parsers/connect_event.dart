import '../exceptions.dart';
import '../models/account.dart';
import '../models/device_info.dart';
import '../models/ton_proof.dart';
import '../models/wallet_info.dart';
import '../types.dart';

enum ConnectEventErrorCodes {
  unknownError,
  badRequestError,
  manifestNotFoundError,
  manifestConnectError,
  unknownAppError,
  userRejectsError,
  methodNotSupported
}

class ConnectEventErrors {
  static TonConnectError getError(ConnectEventErrorCodes errorCodes, String? message) {
    switch (errorCodes) {
      case ConnectEventErrorCodes.unknownError:
        return UnknownError(message);
      case ConnectEventErrorCodes.badRequestError:
        return BadRequestError(message);
      case ConnectEventErrorCodes.manifestNotFoundError:
        return ManifestNotFoundError(message);
      case ConnectEventErrorCodes.manifestConnectError:
        return ManifestContentError(message);
      case ConnectEventErrorCodes.unknownAppError:
        return UnknownAppError(message);
      case ConnectEventErrorCodes.userRejectsError:
        return UserRejectsError(message);
      case ConnectEventErrorCodes.methodNotSupported:
        return ManifestContentError(message);
      default:
        return UnknownError(message);
    }
  }
}

class ConnectEventParser {
  static WalletInfo parseResponse(Json payload) {
    if (!payload.containsKey('items')) {
      throw TonConnectError('items not contains in payload');
    }

    final wallet = WalletInfo();

    for (final item in payload['items']) {
      if (item.containsKey('name')) {
        if (item['name'] == 'ton_addr') {
          wallet.account = Account.fromMap(item);
        } else if (item['name'] == 'ton_proof') {
          wallet.tonProof = TonProof.fromMap(item);
        }
      }
    }

    if (wallet.account == null) {
      throw TonConnectError('ton_addr not contains in items');
    }

    wallet.device = DeviceInfo.fromMap(payload['device']);

    return wallet;
  }

  static TonConnectError parseError(Json payload) {
    final message = payload['error']?['message'];
    var code = payload['error']?['code'];

    if (code == null || ConnectEventErrorCodes.values.contains(code)) {
      code = ConnectEventErrorCodes.unknownError;
    }
    return ConnectEventErrors.getError(code, message);
  }
}
