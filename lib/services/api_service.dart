import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _myApiKey = 'e76d6c475aa56272b74bce8d5e1934f8';


  static Future<Map<String, double>> fetchLiveRates({
    required String source,
    required List<String> currencies,
  }) async {
    final joinedCurrencies = currencies.join(',');

    final url = Uri.parse(
      'http://api.exchangerate.host/live'
          '?access_key=$_myApiKey'
          '&source=$source'
          '&currencies=$joinedCurrencies'
          '&format=1',
    );

    print('--- ApiService.fetchLiveRates ---');
    print('URL: $url');

    final response = await http.get(url);
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        if (data['quotes'] == null) {
          throw Exception('Vastuses puudub "quotes": $data');
        }

        final quotes = data['quotes'] as Map<String, dynamic>;
        final Map<String, double> result = {};
        quotes.forEach((key, value) {
          if (value is num) {
            result[key] = value.toDouble();
          }
        });

        return result;
      } else {
        throw Exception('API viga: ${data['error'] ?? data}');
      }
    } else {
      throw Exception('Serveri viga (status: ${response.statusCode})');
    }
  }
}
