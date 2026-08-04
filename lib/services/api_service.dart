import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class APIService {
  final String? _apiURL = dotenv.env['BASE_API_URL'];

  Future<dynamic> fetchData(String uri) async {
    if(_apiURL == null) {
      throw Exception('Empty URL');
    }

    final url = Uri.parse('$_apiURL/api/upload');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Connection failed: $e";
    }
  }
}
