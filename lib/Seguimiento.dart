import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/api_service.dart';

class SeguimientoScreen extends StatefulWidget {
  const SeguimientoScreen({super.key});

  @override
  State<SeguimientoScreen> createState() => _SeguimientoScreenState();
}

class _SeguimientoScreenState extends State<SeguimientoScreen> {
  List resumenHoy = [];
  List semana = [];
  List horas = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final r1 = await ApiService.getJson('/seguimientos/hoy');
      final r2 = await ApiService.getJson('/seguimientos/semana');
      final r3 = await ApiService.getJson('/seguimientos/horas');

      setState(() {
        resumenHoy = r1;
        semana = r2;
        horas = r3;
        loading = false;
      });
    } catch (e) {
      print('Error al cargar seguimientos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text('Seguimiento Diario'),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen de Hoy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            resumenHoy.isEmpty
                ? Text('No has registrado comidas hoy.')
                : Column(
              children: resumenHoy.map((e) {
                return Card(
                  child: ListTile(
                    title: Text(e['comida']),
                    subtitle: Text('Calorías: ${e['calorias']}, Azúcar: ${e['azucar']}, Carbs: ${e['carbohidratos']}'),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 30),
            Text('Progreso Semanal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 250, child: lineaGrafica()),
            SizedBox(height: 30),
            Text('Distribución por Hora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 300, child: barrasHora()),
          ],
        ),
      ),
    );
  }

  Widget lineaGrafica() {
    if (semana.isEmpty) return Center(child: Text('Sin datos'));

    List<FlSpot> puntos = [];
    for (int i = 0; i < semana.length; i++) {
      final d = semana[i];
      puntos.add(FlSpot(
        i.toDouble(),
        double.tryParse(d['calorias'].toString()) ?? 0.0,
      ));
    }

    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: puntos,
          isCurved: true,
          barWidth: 3,
          color: Colors.green,
          dotData: FlDotData(show: false),
        )
      ],
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
    ));
  }

  Widget barrasHora() {
    if (horas.isEmpty) return Center(child: Text('Sin datos'));

    return BarChart(BarChartData(
      barGroups: horas.map((e) {
        return BarChartGroupData(
          x: int.tryParse(e['hora'].toString()) ?? 0,
          barRods: [
            BarChartRodData(
              toY: double.tryParse(e['calorias'].toString()) ?? 0.0,
              color: Colors.orange,
              width: 10,
            )
          ],
        );
      }).toList(),
      titlesData: FlTitlesData(show: true),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
    ));
  }
}