import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ton/tonconnect_ui/components/tonconnect_state.dart';

class TonConnectButton extends StatefulWidget {
  const TonConnectButton({super.key});

  @override
  State<TonConnectButton> createState() => _TonConnectButtonState();
}

class _TonConnectButtonState extends State<TonConnectButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TonConnectState>(
      builder: (context, state, child) {
        if (state.connected) {
          return const Text('connected');
        } else {
          return ElevatedButton(
            onPressed: () {
              state.getWallets().then((wallets) {
                showDialog(
                  context: context,
                  builder: (context) => ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Card(
                      child: ListView(
                        shrinkWrap: true,
                        children: wallets.map((e) {
                          return ListTile(
                            onTap: () {
                              state.connect(walletApp: e).then((url) {
                                showDialog(context: context, builder: (context) {
                                  return Center(
                                    child: SizedBox(
                                      width: 400,
                                      height: 400,
                                      child: Card(
                                        color: Colors.white,
                                        child: QrImageView(data: url),
                                      ),
                                    ),
                                  );
                                },);
                              });
                            },
                            leading: Image.network(e.image),
                            title: Text(e.name),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              });
            },
            child: const Text('Let\'s connect'),
          );
        }
      },
    );
  }
}
