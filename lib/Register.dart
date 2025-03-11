import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String selectedGender = 'Masculino';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Registro', style: TextStyle(color: Colors.green)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField('Nombre', 'Ingresar nombre'),
              buildTextField('Apellido paterno', 'Ingresar primer apellido'),
              buildTextField('Apellido materno', 'Ingresar segundo apellido'),
              SizedBox(height: 10),
              Text('Género', style: labelStyle()),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  genderButton('Masculino'),
                  genderButton('Femenino'),
                  genderButton('Otro'),
                ],
              ),
              SizedBox(height: 10),
              buildTextField('Enfermedades', 'Ingresa si cuentas con alguna enfermedad'),
              buildTextField('Alergias', 'Ingresa tus alergias'),
              buildTextField('Dirección de correo electrónico', 'Ingresar Correo Electronico'),
              buildTextField('Contraseña', 'Ingresar Contraseña', obscureText: true),
              buildTextField('Confirmar contraseña', 'Repite tu Contraseña', obscureText: true),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Registrarse', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, String hint, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(label, style: labelStyle()),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget genderButton(String gender) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedGender = gender;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedGender == gender ? Colors.green : Colors.grey[200],
          foregroundColor: selectedGender == gender ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(gender),
      ),
    );
  }

  TextStyle labelStyle() {
    return TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green);
  }
}
