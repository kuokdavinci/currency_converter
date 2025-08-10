
import '../models/currency_model.dart';
import '../models/rate_model.dart';
import '../services/currency_api_service.dart';

class CurrencyRepository {
  final CurrencyApiService _apiService;

  CurrencyRepository(this._apiService);

  Future<List<CurrencyModel>> getAllCurrencies() async {
    final data = await _apiService.getAllCurrencies(); // Map<String, String>
    return data.entries
        .map((entry) => CurrencyModel.fromJson(entry))
        .toList();
  }

  Future<RateModel> getRates(String baseCurrency) async {
    final rawData = await _apiService.getRates(baseCurrency); // Map<String, dynamic>
    return RateModel.fromJson(rawData);
  }
}