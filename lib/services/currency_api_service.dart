import 'dart:convert';
import 'dart:io'; // để bắt lỗi SocketException
import 'package:http/http.dart' as http;

class CurrencyApiService {
  final String _baseUrl =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1';

  Future<Map<String, String>> getAllCurrencies() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/currencies.json'));

      if (res.statusCode != 200) {
        throw Exception('Failed to load currencies, status code: ${res.statusCode}');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data.map((k, v) => MapEntry(k, v.toString()));
    } on SocketException catch (_) {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> getRates(String base) async {
    try {
      final res =
      await http.get(Uri.parse('$_baseUrl/currencies/${base.toLowerCase()}.json'));

      if (res.statusCode != 200) {
        throw Exception('Failed to load rates, status code: ${res.statusCode}');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data;
    } on SocketException catch (_) {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
