import 'package:flutter/material.dart';

class RegisterSpecialistScreen extends StatefulWidget {
  @override
  _RegisterSpecialistScreenState createState() => _RegisterSpecialistScreenState();
}

class _RegisterSpecialistScreenState extends State<RegisterSpecialistScreen> {
  String selectedGender = 'Masculino';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Registro de especialistas', style: TextStyle(color: Colors.green)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField('Nombre', 'Ingresar'),
              buildTextField('Apellido paterno', 'Ingresar'),
              buildTextField('Apellido materno', 'Ingresar'),
              SizedBox(height: 10),
              Text('Género', style: labelStyle()),
              Column(
                children: [
                  RadioListTile(
                    title: Text('Masculino'),
                    value: 'Masculino',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value.toString();
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  RadioListTile(
                    title: Text('Femenino'),
                    value: 'Femenino',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value.toString();
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  RadioListTile(
                    title: Text('Otro'),
                    value: 'Otro',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value.toString();
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
              buildTextField('Especialidad', 'Ingresar'),
              buildTextField('Correo', 'Ingresar'),
              buildTextField('Contraseña', 'Ingresar', obscureText: true),
              buildTextField('Confirmar contraseña', 'Ingresar', obscureText: true),
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
                  child: Text('Registrar', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
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

  TextStyle labelStyle() {
    return TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green);
  }
}