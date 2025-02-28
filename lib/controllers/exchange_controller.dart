import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/exchange_rate.dart';

class ExchangeController extends ChangeNotifier {
  List<ExchangeRate>? liveRates;
  double? selectedRate;
  double? conversionResult;

  bool isLoading = false;
  String errorMessage = '';

  final List<String> currencyList = ['USD', 'AUD', 'CAD', 'PLN', 'MXN', 'JPY', 'EUR', 'GBP'];

  String selectedBase = 'GBP';
  String selectedTarget = 'USD';

  double _lastAmount = 1.0;

  Future<void> fetchRates() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();
    try {
      final result = await ApiService.fetchLiveRates(
        source: 'GBP',
        currencies: ['USD', 'AUD', 'CAD', 'PLN', 'MXN'],
      );
      liveRates = result;
    } catch (e) {
      errorMessage = 'Viga: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSelectedRate() async {
    isLoading = true;
    errorMessage = '';
    selectedRate = null;
    conversionResult = null;
    notifyListeners();
    try {
      final rates = await ApiService.fetchLiveRates(
        source: selectedBase,
        currencies: [selectedTarget],
      );
      if (rates.isNotEmpty) {
        final rateObj = rates.first;
        selectedRate = rateObj.rate;
        calculateConversion(_lastAmount);
      } else {
        errorMessage = 'Kursiandmeid pole saadaval';
      }
    } catch (e) {
      errorMessage = 'Viga: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  void calculateConversion(double amount) {
    _lastAmount = amount;
    if (selectedRate != null) {
      conversionResult = amount * selectedRate!;
      notifyListeners();
    }
  }
}
