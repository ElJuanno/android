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

  TextEditingController alturaController = TextEditingController();
  TextEditingController pesoController = TextEditingController();
  TextEditingController edadController = TextEditingController();
  TextEditingController glucosaController = TextEditingController();

  double? imc;

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

        // Cargar los datos guardados de SharedPreferences
        alturaController.text = prefs.getString('altura') ?? '';
        pesoController.text = prefs.getString('peso') ?? '';
        edadController.text = prefs.getString('edad') ?? '';
        glucosaController.text = prefs.getString('glucosa') ?? '';
        calculateIMC();
      });
    } else {
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

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('altura', alturaController.text);
    await prefs.setString('peso', pesoController.text);
    await prefs.setString('edad', edadController.text);
    await prefs.setString('glucosa', glucosaController.text);

    calculateIMC();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Datos guardados')));
  }

  void calculateIMC() {
    double? altura = double.tryParse(alturaController.text);
    double? peso = double.tryParse(pesoController.text);

    if (altura != null && peso != null && altura > 0) {
      setState(() {
        imc = peso / (altura * altura);
      });
    } else {
      setState(() {
        imc = null;
      });
    }
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
        child: SingleChildScrollView(
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              SizedBox(height: 10),
              Text(
                userData?['email'] ?? 'Correo no disponible',
                style: TextStyle(fontSize: 16, color: Colors.green[700]),
              ),
              SizedBox(height: 30),
              Divider(color: Colors.green[200]),

              /// Información decorativa editable
              _buildInputField('Altura (m)', Icons.height, alturaController, '1.75', true),
              _buildInputField('Peso (kg)', Icons.monitor_weight, pesoController, '70', true),
              _buildInputField('Edad', Icons.cake, edadController, '25', false),
              _buildInputField('Glucosa (mg/dL)', Icons.water_drop, glucosaController, '90', false),

              ListTile(
                leading: Icon(Icons.calculate, color: Colors.green[800]),
                title: Text('IMC'),
                subtitle: Text(imc != null ? imc!.toStringAsFixed(2) : 'Ingrese altura y peso'),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveData,
                child: Text('Guardar Datos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: logout,
                icon: Icon(Icons.logout),
                label: Text("Cerrar sesión"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, TextEditingController controller, String hint, bool isNumeric) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.green[700]),
          filled: true,
          fillColor: Colors.green[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (label == "Altura (m)" || label == "Peso (kg)") {
            calculateIMC();
          }
        },
      ),
    );
  }
}
