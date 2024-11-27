import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ton/tonconnect/exceptions.dart';
import 'package:ton/tonconnect_ui/components/tonconnect_state.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../tonconnect/models/wallet_app.dart';

typedef ConnectHandler = void Function([String? payload]);

typedef TonConnectButtonBuilder = Widget Function(
    BuildContext context,
    TonConnectState state,
    TonConnectButtonState buttonState,
    ConnectHandler handler);

enum TonConnectButtonState { connected, normal, loading, error }

class TonConnectButton extends StatefulWidget {
  final TonConnectButtonBuilder builder;

  const TonConnectButton({super.key, required this.builder});

  @override
  State<TonConnectButton> createState() => _TonConnectButtonState();
}

class _TonConnectButtonState extends State<TonConnectButton> {
  TonConnectButtonState _buttonState = TonConnectButtonState.normal;

  @override
  Widget build(BuildContext context) {
    return Consumer<TonConnectState>(
      builder: (context, state, child) {
        return widget.builder(context, state, _buttonState, ([String? payload]) {
          if (!state.connected) {
            setState(() {
              _buttonState = TonConnectButtonState.loading;
            });
            state.getWallets().then((wallets) {
              setState(() {
                _buttonState = TonConnectButtonState.loading;
              });
              showDialog(
                context: context,
                builder: (context) => ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: TonConnectDialog(
                      wallets: wallets,
                      state: state,
                      payload: payload,
                    ),
                  ),
                ),
              ).whenComplete(() {
                if (state.connected) {
                  setState(() {
                    _buttonState = TonConnectButtonState.connected;
                  });
                } else {
                  setState(() {
                    _buttonState = TonConnectButtonState.normal;
                  });
                }
              });
            }).catchError((e) {
              setState(() {
                _buttonState = TonConnectButtonState.error;
              });
            });
          } else {
            // TODO: Already Connected
          }
        });
      },
    );
  }
}

class TonConnectDialog extends StatefulWidget {
  final List<WalletApp> wallets;
  final TonConnectState state;
  final String? payload;

  const TonConnectDialog(
      {super.key, required this.wallets, required this.state, this.payload});

  @override
  State<TonConnectDialog> createState() => _TonConnectDialogState();
}

class _TonConnectDialogState extends State<TonConnectDialog> {
  String? _connectionUrl;
  WalletApp? _selectedWallet;

  @override
  void initState() {
    widget.state.addListener(_listenToConnectionStatus);
    super.initState();
  }

  @override
  void dispose() {
    widget.state.removeListener(_listenToConnectionStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _connectionUrl != null
                  ? IconButton(
                      onPressed: () {
                        if (_connectionUrl != null) {
                          setState(() {
                            _connectionUrl = null;
                          });
                        }
                      },
                      icon: Icon(_connectionUrl != null
                          ? Icons.arrow_back
                          : Icons.qr_code))
                  : const SizedBox.shrink(),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect your wallet',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          Text(
            _connectionUrl != null
                ? 'Scan with your mobile wallet'
                : 'Open Wallet in Telegram or select your wallet to connect',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_connectionUrl != null) ...[
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: QrImageView(
                  data: _connectionUrl!,
                  backgroundColor: Colors.white,
                  embeddedImage: _selectedWallet != null
                      ? NetworkImage(_selectedWallet!.image, scale: 0.9)
                      : null,
                ),
              ),
            ),
            SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () {
                    launchUrlString(_connectionUrl!);
                  },
                  child: const Text('Open Wallet'),
                )),
            const SizedBox(height: 8),
          ],
          if (_connectionUrl == null)
            ...widget.wallets.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () {
                    widget.state
                        .connect(
                            walletApp: e,
                            request: widget.payload != null
                                ? {'ton_proof': widget.payload}
                                : null)
                        .then((url) {
                      setState(() {
                        _selectedWallet = e;
                        _connectionUrl = url;
                      });
                    }).catchError((e) {
                      if (e is WalletAlreadyConnectedError) {
                        // TODO: wallet already connected!
                      }
                    });
                  },
                  horizontalTitleGap: 8,
                  leading: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          e.image,
                          fit: BoxFit.cover,
                        )),
                  ),
                  title: Text(
                    e.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _listenToConnectionStatus() {
    if (widget.state.connected) {
      Navigator.pop(context);
    }
  }
}
