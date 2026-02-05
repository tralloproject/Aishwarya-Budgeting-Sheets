import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _baseUrl = 'https://api.frankfurter.app/latest?from=USD&to=HKD';

  Future<double> getExchangeRate() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['rates']['HKD'] as num).toDouble();
      }
    } catch (e) {
      print('Error fetching exchange rate: $e');
    }
    // Fallback rate if API fails
    return 7.8;
  }

  double convertHKDtoUSD(double hkd, double rate) {
    return hkd / rate;
  }

  double convertUSDtoHKD(double usd, double rate) {
    return usd * rate;
  }
}
