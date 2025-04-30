import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const _base = 'http://209.38.70.113/public/api';     // <-- la IP pública

  // ---------- REGISTER ----------
  static Future<void> register(
      String name, String email, String pass, String pass2) async {
    final res = await http.post(
      Uri.parse('$_base/register'),
      headers: {'Accept': 'application/json','Content-Type':'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': pass,
        'password_confirmation': pass2,
      }),
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Registro falló → ${res.statusCode}: ${res.body}');
    }
  }

  // ---------- LOGIN ----------
  static Future<void> login(String email, String pass) async {
    final res = await http.post(
      Uri.parse('$_base/login'),
      headers: {'Accept': 'application/json','Content-Type':'application/json'},
      body: jsonEncode({'email': email, 'password': pass}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);   // guarda token
    } else {
      throw Exception('Login falló → ${res.statusCode}: ${res.body}');
    }
  }

  // ---------- EJEMPLO de endpoint protegido ----------
  static Future<Map<String,dynamic>> me() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.get(
        Uri.parse('$_base/user'),
        headers:{
          'Authorization':'Bearer $token',
          'Accept':'application/json'
        });
    if (res.statusCode==200) return jsonDecode(res.body);
    throw Exception('me() → ${res.statusCode}: ${res.body}');
  }
}
