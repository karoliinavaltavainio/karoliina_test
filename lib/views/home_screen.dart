import 'package:flutter/material.dart';
import '/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, double>? liveRates;
  double? _selectedRate;
  double? _conversionResult;

  bool isLoading = false;
  String errorMessage = '';

  final List<String> currencyList = ['USD', 'AUD', 'CAD', 'PLN', 'MXN', 'JPY', 'EUR', 'GBP'];
  String _selectedBase = 'GBP';
  String _selectedTarget = 'USD';

  final TextEditingController _amountController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final result = await ApiService.fetchLiveRates(
        source: 'GBP',
        currencies: ['USD', 'AUD', 'CAD', 'PLN', 'MXN'],
      );
      setState(() {
        liveRates = result;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Viga: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchSelectedRate() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      _selectedRate = null;
      _conversionResult = null;
    });
    try {
      final result = await ApiService.fetchLiveRates(
        source: _selectedBase,
        currencies: [_selectedTarget],
      );
      setState(() {
        _selectedRate = result['$_selectedBase$_selectedTarget'];
      });
      _calculateConversion();
    } catch (e) {
      setState(() {
        errorMessage = 'Viga: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _calculateConversion() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (_selectedRate != null) {
      setState(() {
        _conversionResult = amount * _selectedRate!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter by Karoliina'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRates,
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'images/currencyexch.png',
                  fit: BoxFit.contain,
                  width: 200,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const Text(
                      'Select Currency',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: _selectedBase,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          dropdownColor: Colors.black,
                          items: currencyList.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency, style: const TextStyle(fontSize: 18, color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedBase = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.arrow_forward, size: 24, color: Colors.white),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: _selectedTarget,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          dropdownColor: Colors.black,
                          items: currencyList.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency, style: const TextStyle(fontSize: 18, color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedTarget = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.teal, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        if (_selectedRate != null) {
                          _calculateConversion();
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _fetchSelectedRate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Convert'),
                    ),
                    const SizedBox(height: 10),
                    _conversionResult != null
                        ? Text(
                      '${_amountController.text} $_selectedBase = ${_conversionResult!.toStringAsFixed(4)} $_selectedTarget',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                        : const SizedBox(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : errorMessage.isNotEmpty
                  ? Text(errorMessage, style: const TextStyle(color: Colors.red))
                  : liveRates != null
                  ? _buildRatesListView()
                  : const Text('Kursiandmeid pole saadaval', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatesListView() {
    final entries = liveRates!.entries.toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final symbol = entries[index].key;
        final rateValue = entries[index].value;
        final sourceCurrency = symbol.substring(0, 3);
        final targetCurrency = symbol.substring(3);
        return Card(
          elevation: 4,
          color: Colors.grey[850],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.currency_exchange, color: Colors.teal),
            title: Text(
              '$sourceCurrency → $targetCurrency',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              '1 $sourceCurrency = ${rateValue.toStringAsFixed(4)} $targetCurrency',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
