import 'package:flutter/material.dart';
import 'package:pru/RegisterInstitucion.dart';
import 'package:pru/RegisterEspecialista.dart';
import 'package:pru/Register.dart';
import 'package:pru/Sobre.dart';
import 'package:pru/Medidas.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRegisterType = 'Usuario';
  List<String> registerOptions = ['Institución', 'Especialista', 'Usuario'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Image.asset('assets/logo.png', height: 100),
            SizedBox(height: 10),
            Text(
              'Dietali no sustituye el consejo médico profesional.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            // Email Field
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Correo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Ingresa tu correo electrónico',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 15),
            // Password Field
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contraseña',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Ingresa tu contraseña',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Login Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NutritionalMeasuresScreen()),
                );
              },
              child: Text(
                "Iniciar Sesion",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: 15),
            // Register Dropdown with Custom Design
            Text("\n¿No tienes cuenta? Crea Una", style: TextStyle(color: Colors.black)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRegisterType,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.green),
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRegisterType = newValue!;
                    });
                  },
                  items: registerOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (selectedRegisterType == 'Institución') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterInstitutionScreen()),
                  );
                } else if (selectedRegisterType == 'Especialista') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterSpecialistScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Registrarse",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 30),
            // About Us Section
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutScreen()),
                );
              },
              child: Text(
                "Sobre Nosotros",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
