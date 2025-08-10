import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApiService {
  final String _baseUrl =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1';

  Future<Map<String, String>> getAllCurrencies() async {
    final res = await http.get(Uri.parse('$_baseUrl/currencies.json'));
    if (res.statusCode != 200) throw Exception('Failed to load currencies');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<Map<String, dynamic>> getRates(String base) async {
    final res = await http
        .get(Uri.parse('$_baseUrl/currencies/${base.toLowerCase()}.json'));
    if (res.statusCode != 200) throw Exception('Failed to load rates');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data;
  }
}
