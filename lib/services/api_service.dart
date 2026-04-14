import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<dynamic>> searchFood(String query) async {
    final url = Uri.parse(
        "https://tr.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['products'] as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      print("Bağlantı hatası: $e");
      return [];
    }
  }
}