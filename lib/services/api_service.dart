import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Registro
  static Future<void> register(
      String nombre,
      String apellidoP,
      String apellidoM,
      String sexo,
      String curp,
      String correo,
      String contrasena,
      String contrasenaConfirm,
      ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'apellido_p': apellidoP,
        'apellido_m': apellidoM,
        'sexo': sexo,
        'curp': curp,
        'correo': correo,
        'contrasena': contrasena,
        'contrasena_confirmation': contrasenaConfirm,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Registro falló → ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['access_token']);
  }

  // Login
  static Future<void> login(String correo, String contrasena) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
    } else {
      throw Exception('Login falló → ${res.statusCode}: ${res.body}');
    }
  }

  // Obtener usuario
  static Future<Map<String, dynamic>> me() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final res = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('me() → ${res.statusCode}: ${res.body}');
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final res = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      await prefs.remove('token');
      return;
    }
    throw Exception('Logout falló → ${res.statusCode}: ${res.body}');
  }

  // Obtener perfil
  static Future<Map<String, dynamic>> getPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('$baseUrl/perfil'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error al obtener perfil → ${res.statusCode}: ${res.body}');
    }
  }

  // Actualizar perfil
  static Future<void> updatePerfil(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.put(
      Uri.parse('$baseUrl/perfil'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (res.statusCode != 200) {
      throw Exception('Error al actualizar perfil → ${res.statusCode}: ${res.body}');
    }
  }

  // Obtener medidas salud
  static Future<Map<String, dynamic>> getMedidasSalud() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final res = await http.get(
      Uri.parse('$baseUrl/medidas-salud'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error al obtener medidas → ${res.statusCode}: ${res.body}');
    }
  }

  // Guardar medidas salud
  static Future<void> saveMedidasSalud(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final res = await http.post(
      Uri.parse('$baseUrl/medidas-salud'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (res.statusCode != 200) {
      throw Exception('Error al guardar medidas → ${res.statusCode}: ${res.body}');
    }
  }

  // Obtener plan alimenticio
  static Future<Map<String, dynamic>> getPlanAlimenticio() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('$baseUrl/plan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body)['agrupadas'] ?? {};
    } else {
      throw Exception('Error al obtener plan → ${res.statusCode}: ${res.body}');
    }
  }

  // Registrar comida
  static Future<void> registrarComida({
    required String nombre,
    required String hora,
    required double calorias,
    required double azucar,
    required double carbohidratos,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.post(
      Uri.parse('$baseUrl/comida/registrar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': nombre,
        'hora': hora,
        'calorias': calorias,
        'azucar': azucar,
        'carbohidratos': carbohidratos,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception('Error al registrar comida: ${res.statusCode} → ${res.body}');
    }
  }

  // Obtener seguimiento
  static Future<Map<String, dynamic>> obtenerSeguimiento() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("No se encontró el token.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/seguimiento'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar datos de seguimiento');
    }
  }

  // Método auxiliar para otras peticiones GET
  static Future<dynamic> getJson(String endpoint) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final res = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error al cargar datos: ${res.statusCode}');
    }
  }
}
