import 'package:flutter/material.dart';
import 'package:flutter_call_api/states/currency-exchange.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonDecode

class CurrencyExchangeRatePageState extends State<CurrencyExchangeRatePage> {
  Map<String, dynamic>? _cashFlowData;
  bool _isLoading = false;
  String _errorMessage = '';
  final TextEditingController _symbolController = TextEditingController();
  String _currentSymbol = 'MSFT'; // Default symbol

  @override
  void initState() {
    super.initState();
    _fetchCashFlowData(_currentSymbol);
  }

  Future<void> _fetchCashFlowData(String symbol) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final String apiUrl =
        'https://real-time-finance-data.p.rapidapi.com/company-cash-flow?symbol=$symbol&period=ANNUAL&language=en';
    const String apiHost = 'real-time-finance-data.p.rapidapi.com';
    const String apiKey = '40cf7ffcaemsha500262f5e582f1p1613f5jsn4d2286c415ce';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'x-rapidapi-host': apiHost, 'x-rapidapi-key': apiKey},
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _cashFlowData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchSubmitted(String symbol) {
    if (symbol.isNotEmpty) {
      setState(() {
        _currentSymbol = symbol.toUpperCase(); // Convert to uppercase
      });
      _fetchCashFlowData(_currentSymbol);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Currency Exchange Rate')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _symbolController,
              decoration: InputDecoration(
                hintText: 'Enter stock symbol (e.g., MSFT, AAPL)',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _onSearchSubmitted(_symbolController.text);
                  },
                ),
              ),
              onSubmitted: _onSearchSubmitted,
            ),
          ),
          // Data Display
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : _cashFlowData != null
                    ? SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            '${_cashFlowData!["data"]["symbol"]} - ${_cashFlowData!["data"]["type"]}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          // Metrics Table
                          Card(
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Table Header
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Date',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Net Income',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Cash Ops',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Cash Inv',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Cash Fin',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Net Change',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Free Cash',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  // Table Rows
                                  ..._cashFlowData!["data"]["cash_flow"].map<
                                    Widget
                                  >((data) {
                                    return Container(
                                      color:
                                          _cashFlowData!["data"]["cash_flow"]
                                                          .indexOf(data) %
                                                      2 ==
                                                  0
                                              ? Colors.grey[200]
                                              : Colors.white,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(data["date"]),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '\$${(data["net_income"] / 1e9).toStringAsFixed(2)}B',
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '\$${(data["cash_from_operations"] / 1e9).toStringAsFixed(2)}B',
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '\$${(data["cash_from_investing"] / 1e9).toStringAsFixed(2)}B',
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '\$${(data["cash_from_financing"] / 1e9).toStringAsFixed(2)}B',
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '\$${(data["net_change_in_cash"] / 1e9).toStringAsFixed(2)}B',
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '\$${(data["free_cash_flow"] / 1e9).toStringAsFixed(2)}B',
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : Center(child: Text('No data available')),
          ),
        ],
      ),
    );
  }
}
