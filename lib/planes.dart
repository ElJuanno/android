import 'package:flutter/material.dart';

class PlanAlimenticio {
  final String titulo;
  final List<String> opciones;
  final IconData icono;

  PlanAlimenticio({
    required this.titulo,
    required this.opciones,
    required this.icono,
  });
}

class PlanesScreen extends StatelessWidget {
  final List<PlanAlimenticio> planes = [
    PlanAlimenticio(
      titulo: 'Desayuno',
      opciones: [
        'Avena con frutas y yogur natural',
        'Tostadas integrales con aguacate',
        'Panqueques de avena y banana',
        'Huevos revueltos con espinacas',
        'Batido verde con espinacas y manzana',
      ],
      icono: Icons.breakfast_dining,
    ),
    PlanAlimenticio(
      titulo: 'Almuerzo',
      opciones: [
        'Ensalada de pollo y quinoa',
        'Sopa de verduras con pollo',
        'Arroz integral con verduras salteadas',
        'Pasta integral con salsa de tomate',
        'Filete de salmón con espárragos',
      ],
      icono: Icons.lunch_dining,
    ),
    PlanAlimenticio(
      titulo: 'Cena',
      opciones: [
        'Pescado a la plancha con batata asada',
        'Sopa de lentejas y zanahorias',
        'Tortilla de espinacas y queso feta',
        'Ensalada de atún con garbanzos',
        'Calabacines rellenos de carne magra',
      ],
      icono: Icons.dinner_dining,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planes Alimenticios'),
        backgroundColor: Colors.green[700],
        elevation: 0,
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
          child: ListView.builder(
            itemCount: planes.length,
            itemBuilder: (context, index) {
              final plan = planes[index];
              return _buildExpandableCard(plan);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableCard(PlanAlimenticio plan) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.green[100]!, Colors.green[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green[600],
            shape: BoxShape.circle,
          ),
          child: Icon(
            plan.icono,
            color: Colors.white,
            size: 30,
          ),
        ),
        title: Text(
          plan.titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.green[800],
          ),
        ),
        children: plan.opciones
            .map((opcion) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700], size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  opcion,
                  style: TextStyle(fontSize: 14, color: Colors.green[800]),
                ),
              ),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }
}
