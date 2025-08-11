import 'package:currency_converter/models/rate_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:currency_converter/models/currency_model.dart';
import 'package:currency_converter/viewmodels/currency_view_model.dart';
import 'mocks.mocks.dart';

void main() {
  late MockCurrencyRepository mockRepository;
  late CurrencyViewModel viewModel;

  setUp(() {
    mockRepository = MockCurrencyRepository();
    viewModel = CurrencyViewModel(mockRepository);
  });

  group('CurrencyViewModel', () {
    test('loadCurrencies - success', () async {
      final fakeCurrencies = [
        CurrencyModel(code: 'USD', name: 'US Dollar'),
        CurrencyModel(code: 'EUR', name: 'Euro'),
      ];
      when(mockRepository.getAllCurrencies())
          .thenAnswer((_) async => fakeCurrencies);

      await viewModel.loadCurrencies();

      expect(viewModel.currencies.length, 2);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      verify(mockRepository.getAllCurrencies()).called(1);
    });

    test('loadCurrencies - fail', () async {
      when(mockRepository.getAllCurrencies())
          .thenThrow(Exception('Network error'));

      await viewModel.loadCurrencies();

      expect(viewModel.currencies.isEmpty, true);
      expect(viewModel.isLoading, false);
      verify(mockRepository.getAllCurrencies()).called(1);
    });

    test('convert - success', () async {
      viewModel.fromCurrency = 'USD';
      viewModel.toCurrency = 'EUR';
      viewModel.amount = 100;

      when(mockRepository.getRates('USD')).thenAnswer((_) async =>
          RateModel(
            date: '2025-08-11',
            baseCurrency: 'USD',
            rates: {'EUR': 0.85},
          ));

      await viewModel.convert();

      expect(viewModel.result, 85);
      expect(viewModel.errorMessage, null);
      verify(mockRepository.getRates('USD')).called(1);
    });

    test('convert', () async {
      viewModel.fromCurrency = 'USD';
      viewModel.toCurrency = 'JPY';
      viewModel.amount = 100;

      when(mockRepository.getRates('USD')).thenAnswer((_) async =>
          RateModel(
            date: '2025-08-11',
            baseCurrency: 'USD',
            rates: {'EUR': 0.85},
          ));

      await viewModel.convert();

      expect(viewModel.result, null);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('swapCurrencies', () async {
      viewModel.fromCurrency = 'USD';
      viewModel.toCurrency = 'EUR';
      viewModel.amount = 10;

      when(mockRepository.getRates('EUR')).thenAnswer((_) async =>
          RateModel(
            date: '2025-08-11',
            baseCurrency: 'EUR',
            rates: {'USD': 2.0},
          ));

      viewModel.swapCurrencies();

      expect(viewModel.fromCurrency, 'EUR');
      expect(viewModel.toCurrency, 'USD');

      await Future.delayed(Duration.zero);
      expect(viewModel.result, 20);
    });

    test('convertCurrency', () async {
      viewModel.fromCurrency = 'USD';
      viewModel.toCurrency = 'EUR';

      when(mockRepository.getRates('USD')).thenAnswer((_) async =>
          RateModel(
            date: '2025-08-11',
            baseCurrency: 'USD',
            rates: {'EUR': 1.5},
          ));

      viewModel.convertCurrency("200");

      await Future.delayed(Duration.zero);

      expect(viewModel.amount, 200);
      expect(viewModel.result, 300);
    });
  });
}
