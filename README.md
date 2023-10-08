# ton

Ton Sdk for Flutter.
This project uses `org.ton:ton-kotlin:0.2.15` for native android calls and does not support web, linux and windows yet.

## Getting Started

First of all initiate a `Ton` variable
```dart
final _tonPlugin = Ton();
```

Generating a random mnemonic:
```dart
_tonPlugin.randomMnemonic();
```
This function will return a Future of List of Strings which are the seed to your wallet.

Generating a random mnemonic with password:
For doing this you have to pass the password as a String parameter.
```dart
_tonPlugin.randomMnemonic(password: "YOU_WALLET_PASSWORD");
```
This function will also return a Future of List of Strings which are the seed to your ton wallet.

## Web Configuration

Add the files in example project under `web` directory to your project and then add the script below to your `index.html` file
```dart
  <script src="ton-mnemonic/web/index.js"></script>
```

The files can be found here:
[Web Mnemonic Library](./example/web/ton-mnemonic)