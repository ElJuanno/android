import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'General.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  final String baseUrl = 'http://209.38.70.113/api';

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("Aceptar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void register() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse('$baseUrl/register');
    var response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'password_confirmation': confirmPasswordController.text.trim(),
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      handleSuccessfulRegistration(response);
    } else {
      handleRegisterError(response);
    }
  }

  void handleSuccessfulRegistration(http.Response response) async {
    try {
      var data = json.decode(response.body);

      if (data.containsKey('token')) {
        String token = data['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      } else {
        showErrorDialog(context, "No se recibió un token. Verifica tu conexión.");
      }
    } catch (e) {
      showErrorDialog(context, "Error al procesar la respuesta del servidor.");
    }
  }

  void handleRegisterError(http.Response response) {
    try {
      var data = json.decode(response.body);

      if (data.containsKey('message')) {
        showErrorDialog(context, data['message']);
      } else if (data.containsKey('errors')) {
        var errors = data['errors'];
        if (errors.containsKey('email')) {
          showErrorDialog(context, "Correo ya registrado.");
        } else if (errors.containsKey('password')) {
          showErrorDialog(context, "Error en la contraseña.");
        } else {
          showErrorDialog(context, "Error al registrar. Verifica los datos.");
        }
      } else {
        showErrorDialog(context, "Error al registrar. Intenta nuevamente.");
      }
    } catch (e) {
      showErrorDialog(context, "Error inesperado. Intenta nuevamente.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 60),
                Image.asset('assets/logo.png', height: 120),
                SizedBox(height: 20),
                Text(
                  'Crea tu cuenta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 30),
                _buildTextField('Nombre', Icons.person, nameController, false),
                SizedBox(height: 15),
                _buildTextField('Correo electrónico', Icons.email, emailController, false),
                SizedBox(height: 15),
                _buildTextField('Contraseña', Icons.lock, passwordController, true),
                SizedBox(height: 15),
                _buildTextField('Confirmar contraseña', Icons.lock_outline, confirmPasswordController, true),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isLoading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Registrarse',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(color: Colors.green[800], decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        filled: true,
        fillColor: Colors.green[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
