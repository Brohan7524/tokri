import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchWeeklyBasket(int familySize) async {
  final response = await http.post(
    Uri.parse(''), // <-- Update this to real API URL when deployed
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'family_size': familySize}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['weekly_basket']);
  } else {
    throw Exception('Failed to fetch basket');
  }
}
