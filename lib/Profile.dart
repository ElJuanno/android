import 'package:flutter/material.dart';
import 'services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> perfil = {};
  bool isLoading = true;

  final TextEditingController nombre = TextEditingController();
  final TextEditingController apellidoP = TextEditingController();
  final TextEditingController apellidoM = TextEditingController();
  final TextEditingController sexo = TextEditingController();
  final TextEditingController curp = TextEditingController();
  final TextEditingController correo = TextEditingController();
  final TextEditingController peso = TextEditingController();
  final TextEditingController altura = TextEditingController();
  String? imc;

  @override
  void initState() {
    super.initState();
    loadPerfil();
  }

  Future<void> loadPerfil() async {
    try {
      final data = await ApiService.getPerfil();
      setState(() {
        perfil = data;
        nombre.text = data['persona']['nombre'] ?? '';
        apellidoP.text = data['persona']['apellido_p'] ?? '';
        apellidoM.text = data['persona']['apellido_m'] ?? '';
        sexo.text = data['persona']['sexo'] ?? '';
        curp.text = data['persona']['curp'] ?? '';
        correo.text = data['persona']['correo'] ?? '';
        peso.text = data['medidas']?['peso']?.toString() ?? '';
        altura.text = data['medidas']?['altura']?.toString() ?? '';
        imc = data['imc']?.toString();
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el perfil')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final double? pesoVal = double.tryParse(peso.text);
      final double? alturaVal = double.tryParse(altura.text);
      if (pesoVal != null && alturaVal != null && alturaVal > 0) {
        setState(() {
          imc = (pesoVal / (alturaVal * alturaVal)).toStringAsFixed(2);
        });
      }

      try {
        await ApiService.updatePerfil({
          'nombre': nombre.text,
          'apellido_p': apellidoP.text,
          'apellido_m': apellidoM.text,
          'sexo': sexo.text,
          'curp': curp.text,
          'correo': correo.text,
          'peso': pesoVal,
          'altura': alturaVal,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cambios guardados correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Mi Perfil'),
        leading: BackButton(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Icon(Icons.account_circle, size: 100, color: Colors.green.shade700),
              const SizedBox(height: 10),
              const Text(
                'Consulta y actualiza tu información',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildInput('Nombre', nombre),
              _buildInput('Apellido paterno', apellidoP),
              _buildInput('Apellido materno', apellidoM),
              _buildInput('Sexo (H o M)', sexo),
              _buildInput('CURP', curp, optional: true),
              _buildInput('Correo electrónico', correo),
              _buildInput('Peso (kg)', peso),
              _buildInput('Altura (m)', altura),
              if (imc != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('IMC: $imc', style: TextStyle(color: Colors.grey[600])),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Guardar cambios', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.green[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: optional
            ? null
            : (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
      ),
    );
  }
}
