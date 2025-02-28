class ExchangeRate {
  final String source;
  final String target;
  final double rate;

  ExchangeRate({
    required this.source,
    required this.target,
    required this.rate,
  });

  factory ExchangeRate.fromKeyValue(String key, dynamic value) {
    if (key.length < 6) {
      throw Exception('Vigane võtme pikkus: $key');
    }
    return ExchangeRate(
      source: key.substring(0, 3),
      target: key.substring(3),
      rate: (value as num).toDouble(),
    );
  }
}
