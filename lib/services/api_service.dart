import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  
  // Para dispositivo físico/emulador Android use:
  // static const String baseUrl = 'http://10.0.2.2:3000';
  
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<dynamic>> getHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/history'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> getReports(String period) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reports/$period'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}