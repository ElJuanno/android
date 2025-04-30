import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final String baseUrl = 'http://209.38.70.113/api';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Token no encontrado.')));
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      print('Error al cargar perfil: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener perfil')));
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text('Perfil del Usuario'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.green[100],
              child: Icon(Icons.person, size: 60, color: Colors.green[800]),
            ),
            SizedBox(height: 20),
            Text(
              userData?['name'] ?? 'Nombre no disponible',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[900]),
            ),
            SizedBox(height: 10),
            Text(
              userData?['email'] ?? 'Correo no disponible',
              style: TextStyle(fontSize: 16, color: Colors.green[700]),
            ),
            SizedBox(height: 30),
            Divider(color: Colors.green[200]),
            ListTile(
              leading: Icon(Icons.badge, color: Colors.green[800]),
              title: Text('Nombre'),
              subtitle: Text(userData?['name'] ?? 'N/A'),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.green[800]),
              title: Text('Correo electrónico'),
              subtitle: Text(userData?['email'] ?? 'N/A'),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: logout,
              icon: Icon(Icons.logout),
              label: Text("Cerrar sesión"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
