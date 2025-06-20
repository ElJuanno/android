import 'package:flutter/material.dart';
import 'services/api_service.dart';

class MedidasSaludScreen extends StatefulWidget {
  const MedidasSaludScreen({super.key});

  @override
  State<MedidasSaludScreen> createState() => _MedidasSaludScreenState();
}

class _MedidasSaludScreenState extends State<MedidasSaludScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController glucosa = TextEditingController();
  final TextEditingController presion = TextEditingController();
  final TextEditingController frecuencia = TextEditingController();
  final TextEditingController edad = TextEditingController();

  String? condicionSeleccionada;

  bool isLoading = true;

  final List<String> condiciones = [
    'Ninguna',
    'Diabetes',
    'Obesidad',
    'Hipertensión',
    'Colesterol Alto',
  ];

  @override
  void initState() {
    super.initState();
    loadMedidas();
  }

  Future<void> loadMedidas() async {
    try {
      final data = await ApiService.getMedidasSalud();
      if (data.isNotEmpty) {
        glucosa.text = (data['glucosa'] ?? '').toString();
        presion.text = (data['presion'] ?? '').toString();
        frecuencia.text = (data['frecuencia'] ?? '').toString();
        condicionSeleccionada = data['condicion'] ?? 'Ninguna';
        edad.text = (data['edad'] ?? '').toString();
      } else {
        condicionSeleccionada = 'Ninguna';
      }
    } catch (e) {
      print('Error al cargar medidas: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> guardarMedidas() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ApiService.saveMedidasSalud({
          'glucosa': double.tryParse(glucosa.text),
          'presion': presion.text,
          'frecuencia': frecuencia.text,
          'condicion': condicionSeleccionada,
          'edad': int.tryParse(edad.text),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medidas guardadas correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Widget _buildInput(String label, TextEditingController controller, {bool isNumeric = false, bool obligatorio = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.green[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: obligatorio
            ? (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obligatorio';
          }
          if (isNumeric && double.tryParse(value) == null) {
            return 'Debe ser un número válido';
          }
          return null;
        }
            : null,
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: condicionSeleccionada,
        items: condiciones.map((cond) {
          return DropdownMenuItem(
            value: cond,
            child: Text(cond),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Condición',
          filled: true,
          fillColor: Colors.green[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() => condicionSeleccionada = value);
        },
        validator: (value) => value == null ? 'Selecciona una condición' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Registrar Medidas de Salud'),
        leading: const BackButton(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Guarda y actualiza tus parámetros principales',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildInput('Glucosa (mg/dL)', glucosa, isNumeric: true, obligatorio: true),
              _buildInput('Presión arterial', presion),
              _buildInput('Frecuencia cardiaca', frecuencia),
              _buildDropdown(),
              _buildInput('Edad', edad, isNumeric: true, obligatorio: true),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: guardarMedidas,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Guardar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
