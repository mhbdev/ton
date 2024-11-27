# ton

![Flutter Ton Project](https://github.com/mhbdev/ton/assets/53684884/103e400a-6a77-4159-bc1e-5797521c52c9)

Ton Sdk for Flutter.
This project uses `org.ton:ton-kotlin:0.2.15` for native android calls and `https://github.com/toncenter/tonweb-mnemonic` for web support and does not support linux and windows yet.

# Buy me a pizza

If you love this library and want to support its development you can donate any amount of coins to this TON address ☺️:

**UQDKcML9_qEz_YsiUtxxIzaEBwCfAiCfKnM1oHIw5qIVO67S**

You can also send your donations through my [PizzaTon campaign](https://t.me/pizzatonbot/app?startapp=64eac4333f9e4974e96b0a7f61f28828)

## Getting Started

### First of all initiate a `Ton` variable

```dart
final _tonPlugin = Ton();
```

### Generating a random mnemonic:

```dart
_tonPlugin.randomMnemonic();
```
This function will return a Future of List of Strings which are the seed to your wallet.

### Generating a random mnemonic with password:

For doing this you have to pass the password as a String parameter.

```dart
_tonPlugin.randomMnemonic(password: "YOU_WALLET_PASSWORD");
```

This function will also return a Future of List of Strings which are the seed to your ton wallet.

### Check if a mnemonic is valid:

```dart
mnemonic = <String>['a', 'b', ...];
_tonPlugin.isMnemonicValid(mnemonic)
```
You can also pass your mnemonic's password if it has one.

## Web Configuration

Add the files in example project under `web` directory to your project and then add the script below to your `index.html` file
```dart
  <script src="ton-mnemonic/web/index.js"></script>
```

The files can be found here:
[Web Mnemonic Library](./example/web/ton-mnemonic)

## Ton Connect

You can find docs about ton-connect [here](./docs/TONCONNECT.md)

### How to implement TonConnect Wallet connection?

1. Wrap your application with `TonConnectUiProvider`.
2. Use `TonConnectButton` in any inner widget.

# Links

- [Official HACK-TON-BERFEST 2023 Telegram group](https://t.me/hack_ton_berfest_2023)
- [Flutter Ton Sdk Discussion Telegram Group](https://t.me/FlutterTon)
