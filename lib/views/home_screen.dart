import 'package:flutter/material.dart';
import '../controllers/exchange_controller.dart';
import '../models/exchange_rate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ExchangeController controller;
  final TextEditingController _amountController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    controller = ExchangeController();
    controller.fetchRates();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _amountController.dispose();
    super.dispose();
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
            onPressed: controller.fetchRates,
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
                          value: controller.selectedBase,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          dropdownColor: Colors.black,
                          items: controller.currencyList.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency, style: const TextStyle(fontSize: 18, color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                controller.selectedBase = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.arrow_forward, size: 24, color: Colors.white),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: controller.selectedTarget,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          dropdownColor: Colors.black,
                          items: controller.currencyList.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency, style: const TextStyle(fontSize: 18, color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                controller.selectedTarget = val;
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
                        final amount = double.tryParse(value) ?? 0.0;
                        controller.calculateConversion(amount);
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: controller.fetchSelectedRate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Convert'),
                    ),
                    const SizedBox(height: 10),
                    controller.conversionResult != null
                        ? Text(
                      '${_amountController.text} ${controller.selectedBase} = ${controller.conversionResult!.toStringAsFixed(4)} ${controller.selectedTarget}',
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
              controller.isLoading
                  ? const CircularProgressIndicator()
                  : controller.errorMessage.isNotEmpty
                  ? Text(controller.errorMessage, style: const TextStyle(color: Colors.red))
                  : controller.liveRates != null
                  ? _buildRatesListView(controller.liveRates!)
                  : const Text('Kursiandmeid pole saadaval', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatesListView(List<ExchangeRate> rates) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: rates.length,
      itemBuilder: (context, index) {
        final exchangeRate = rates[index];
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
              '${exchangeRate.source} → ${exchangeRate.target}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              '1 ${exchangeRate.source} = ${exchangeRate.rate.toStringAsFixed(4)} ${exchangeRate.target}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
