import 'package:flutter/material.dart';

class RegistroComidaScreen extends StatefulWidget {
  @override
  _RegistroComidaScreenState createState() => _RegistroComidaScreenState();
}

class _RegistroComidaScreenState extends State<RegistroComidaScreen> {
  final TextEditingController _nombreComidaController = TextEditingController();
  final TextEditingController _caloriasController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  final List<Map<String, String>> comidas = [];

  void _agregarComida() {
    if (_nombreComidaController.text.isNotEmpty && _caloriasController.text.isNotEmpty) {
      setState(() {
        comidas.add({
          'nombre': _nombreComidaController.text,
          'calorias': _caloriasController.text,
          'hora': _horaController.text.isNotEmpty ? _horaController.text : "Sin hora",
        });
        _nombreComidaController.clear();
        _caloriasController.clear();
        _horaController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Comidas'),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.green[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Registrar Comida",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
              SizedBox(height: 10),
              _buildInputField("Nombre de la comida", Icons.fastfood, _nombreComidaController, false),
              _buildInputField("Calorías", Icons.local_fire_department, _caloriasController, true),
              _buildInputField("Hora (opcional)", Icons.access_time, _horaController, false),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _agregarComida,
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text("Agregar Comida"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Comidas Registradas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: comidas.length,
                  itemBuilder: (context, index) {
                    final comida = comidas[index];
                    return _buildComidaCard(comida);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, TextEditingController controller, bool isNumeric) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green[700]),
          filled: true,
          fillColor: Colors.green[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildComidaCard(Map<String, String> comida) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[600],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.fastfood, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comida['nombre']!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[800]),
                ),
                Text(
                  "Calorías: ${comida['calorias']} kcal",
                  style: TextStyle(fontSize: 14, color: Colors.green[700]),
                ),
                Text(
                  "Hora: ${comida['hora']}",
                  style: TextStyle(fontSize: 14, color: Colors.green[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red[400]),
            onPressed: () {
              setState(() {
                comidas.remove(comida);
              });
            },
          ),
        ],
      ),
    );
  }
}
