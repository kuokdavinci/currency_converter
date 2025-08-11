import 'package:flutter/material.dart';
import '../models/currency_model.dart';
import '../repositories/currency_repository.dart';

class CurrencyViewModel extends ChangeNotifier {
  final CurrencyRepository repository;

  List<CurrencyModel> currencies = [];
  String? fromCurrency;
  String? toCurrency;
  double amount = 0;
  double? result;
  bool isLoading = false;

  void swapCurrencies() {
    final temp = fromCurrency;
    fromCurrency = toCurrency;
    toCurrency = temp;
    notifyListeners();
    convert();
  }

  void convertCurrency(dynamic amount) {
      amount = double.parse(amount);
      convert();
  }
  CurrencyViewModel(this.repository);

  Future<void> loadCurrencies() async {
    isLoading = true;
    notifyListeners();

    try {
      currencies = await repository.getAllCurrencies();
    } catch (e) {
      debugPrint("Error loading currencies: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> convert() async {
    if (fromCurrency == null || toCurrency == null || amount <= 0) return;

    try {
      final rateModel = await repository.getRates(fromCurrency!);
      final rate = rateModel.rates[toCurrency!];
      if (rate != null) {
        result = amount * rate;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error converting currency: $e");
    }
  }
}

