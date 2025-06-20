import 'package:flutter/material.dart';
import 'services/api_service.dart';

class PlanAlimenticioScreen extends StatefulWidget {
  const PlanAlimenticioScreen({super.key});

  @override
  State<PlanAlimenticioScreen> createState() => _PlanAlimenticioScreenState();
}

class _PlanAlimenticioScreenState extends State<PlanAlimenticioScreen> {
  Map<String, dynamic> plan = {};
  bool loading = true;
  String? error;

  final ordenTiempos = ['Desayuno', 'Almuerzo', 'Comida', 'Cena', 'Snack'];

  @override
  void initState() {
    super.initState();
    obtenerPlan();
  }

  Future<void> obtenerPlan() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await ApiService.getPlanAlimenticio();
      setState(() => plan = data);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FDF7),
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Plan Alimenticio Personalizado'),
      ),
      body: loading
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: Image.asset('assets/Gif1.gif'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Generando tu plan alimenticio...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 10,
              width: 220,
              decoration: BoxDecoration(
                color: Colors.green[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const LinearProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(Color(0xFF43A047)),
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      )
          : error != null
          ? Center(child: Text('Error: $error'))
          : plan.isEmpty
          ? const Center(
          child: Text('No se encontraron recomendaciones'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: ordenTiempos
            .where((t) => plan.containsKey(t))
            .map((tiempo) {
          final recetas = plan[tiempo] as List<dynamic>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tiempo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: recetas
                    .map((receta) => _buildCard(receta))
                    .toList(),
              ),
              const SizedBox(height: 30),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> receta) {
    final calorias = receta['calorias'] ?? 'N/A';
    final azucar = receta['azucar'] ?? 'N/A';
    final carbs = receta['carbohidratos'] ?? 'N/A';
    final nombre = receta['nombre'] ?? 'Sin nombre';
    final categoria = receta['categoria'] ?? 'Sin categoría';
    final ingredientesRaw = receta['ingredientes'] ?? '';
    final ingredientes = ingredientesRaw
        .toString()
        .replaceAll(RegExp(r'c\(|\)|"|character\(0\)'), '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(', ');

    final color = receta['color'] ?? 'verde';
    final Color borderColor = {
      'verde': Colors.green,
      'amarillo': Colors.orange,
      'rojo': Colors.red,
    }[color] ?? Colors.grey;

    final Color backgroundColor = {
      'verde': const Color(0xFFE8F5E9),
      'amarillo': const Color(0xFFFFF8E1),
      'rojo': const Color(0xFFFFEBEE),
    }[color] ?? Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(1, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: borderColor,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style:
                    const TextStyle(color: Colors.black87, fontSize: 13),
                    children: [
                      const TextSpan(
                        text: 'Ingredientes: ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ingredientes),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Categoría: $categoria',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildBadge(Icons.local_fire_department, '$calorias Cal',
                        Colors.green),
                    _buildBadge(
                        Icons.water_drop, '$azucar Azúcar', Colors.orange),
                    _buildBadge(Icons.bubble_chart, '$carbs Carbs',
                        Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => registrarComida(receta),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Seguir'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> registrarComida(Map<String, dynamic> receta) async {
    try {
      final horaActual = TimeOfDay.now().format(context);
      await ApiService.registrarComida(
        nombre: receta['nombre'],
        hora: horaActual,
        calorias: (receta['calorias'] ?? 0).toDouble(),
        azucar: (receta['azucar'] ?? 0).toDouble(),
        carbohidratos: (receta['carbohidratos'] ?? 0).toDouble(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comida registrada correctamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
