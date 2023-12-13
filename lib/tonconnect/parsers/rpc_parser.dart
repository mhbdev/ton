import 'package:ton/tonconnect/types.dart';

abstract class RpcParser {
  Json convertToRpcRequest(Json args);

  Json convertFromRpcResponse(Json rpcResponse);

  void parseAndThrowError(Json response);

  bool isError(Json response);
}