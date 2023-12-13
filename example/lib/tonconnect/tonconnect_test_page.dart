import 'package:flutter/material.dart';
import 'package:ton/tonconnect_ui/components/tonconnect_button.dart';

class TonConnectTestPage extends StatefulWidget {
  const TonConnectTestPage({super.key});

  @override
  State<TonConnectTestPage> createState() => _TonConnectTestPageState();
}

class _TonConnectTestPageState extends State<TonConnectTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          TonConnectButton(),
        ],
      ),
    );
  }
}
