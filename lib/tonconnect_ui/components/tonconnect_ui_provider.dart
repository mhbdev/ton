import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ton/tonconnect_ui/components/tonconnect_state.dart';

class TonConnectUiProvider extends StatelessWidget {
  final Widget child;
  final bool? lazy;
  final String manifestUrl;

  const TonConnectUiProvider({
    super.key,
    required this.child,
    this.lazy,
    required this.manifestUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TonConnectState(
        context: context,
        manifestUrl: manifestUrl,
      ),
      lazy: lazy,
      child: child,
      builder: (context, child) => TonConnectWrapper(child: child!),
    );
  }
}

class TonConnectWrapper extends StatefulWidget {
  final Widget child;

  const TonConnectWrapper({super.key, required this.child});

  @override
  State<TonConnectWrapper> createState() => _TonConnectWrapperState();
}

class _TonConnectWrapperState extends State<TonConnectWrapper> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Provider.of<TonConnectState>(context, listen: false).connected) {
        Provider.of<TonConnectState>(context, listen: false).restoreConnection();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
