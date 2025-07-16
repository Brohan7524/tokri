import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<dynamic>> fetchWeeklyBasket(int familySize) async {
    //final url = Uri.parse('http://127.0.0.1:5000/generate-basket'); // Replace with live URL when deployed
    //final url = Uri.parse('http://10.0.2.2:5000/generate-basket');
    final url = Uri.parse('https://tokri1admin.pythonanywhere.com/generate-basket');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'familySize': familySize}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // List of 7 daily baskets
    } else {
      throw Exception('Failed to fetch basket: ${response.statusCode}');
    }
  }
}
