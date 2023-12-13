enum Chain {
  mainnet(-239),
  testnet(-3);

  const Chain(this.value);
  final int value;

  static Chain getChainByValue(int code) {
    return Chain.values.firstWhere((e) => e.value == code);
  }
}