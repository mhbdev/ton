import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ton/ton.dart';
import 'package:ton/tonconnect_ui/components/tonconnect_ui_provider.dart';

import 'tonconnect/tonconnect_test_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _tonPlugin = Ton();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _tonPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return TonConnectUiProvider(
          manifestUrl:
              'https://raw.githubusercontent.com/XaBbl4/pytonconnect/main/pytonconnect-manifest.json',
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Running on: $_platformVersion\n'),
                FutureBuilder(
                    future: _tonPlugin.randomMnemonic(password: "HELLOWORLD"),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }

                      if (snapshot.hasData && snapshot.data != null) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Mnemonic:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: FutureBuilder(
                                    future:
                                    _tonPlugin.isMnemonicValid(snapshot.data!, 'HELLOWORLD'),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Text(
                                          snapshot.error.toString(),
                                          textAlign: TextAlign.end,
                                          maxLines: 1,
                                        );
                                      }

                                      if (snapshot.hasData && snapshot.data != null) {
                                        return Text(
                                          snapshot.data! ? 'Valid' : 'Invalid',
                                          textAlign: TextAlign.end,
                                          maxLines: 1,
                                        );
                                      }

                                      return const CircularProgressIndicator();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Text(snapshot.data!.join(', ')),
                            const Divider(),
                            FutureBuilder(
                              future: _tonPlugin.toSeed(snapshot.data!),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                }

                                if (snapshot.hasData && snapshot.data != null) {
                                  return Column(
                                    children: [
                                      const Text(
                                        'Seed:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(base64Encode(snapshot.data!)),
                                      const Divider(),
                                    ],
                                  );
                                }

                                return const Text('Converting mnemonic to seed...');
                              },
                            ),
                          ],
                        );
                      }

                      return const Text('Creating random mnemonic...');
                    }),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TonConnectTestPage(),
                        ));
                  },
                  child: const Text('Ton Connect UI'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
