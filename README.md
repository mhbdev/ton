# ton

Ton Sdk for Flutter.
This project uses `org.ton:ton-kotlin:0.2.15` for native android calls and `https://github.com/toncenter/tonweb-mnemonic` for web support and does not support linux and windows yet.

# Table of contents


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

# How to Contribute

Registration: Connect your wallet and fill your GitHub and Telegram accounts in ton society

Fork & Clone: Fork this repository and clone it to your local machine.

Pick an Issue: Browse open issues, choose one that interests you, and commit to it.

Code Away: Address the issue in your local environment.

Pull Request: Submit a PR for review. Please ensure your PR title is clear and your description is detailed.

Contact the team: notify the team of your PR to check the code

# Links

[Official HACK-TON-BERFEST 2023 Telegram group](https://t.me/hack_ton_berfest_2023)
[Flutter Ton Sdk Discussion Telegram Group](https://t.me/FlutterTon)