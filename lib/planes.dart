import 'package:flutter/material.dart';

class PlanAlimenticio {
  final String titulo;
  final String descripcion;
  final String horario;

  PlanAlimenticio({
    required this.titulo,
    required this.descripcion,
    required this.horario,
  });
}

class PlanesScreen extends StatelessWidget {
  final List<PlanAlimenticio> planes = [
    PlanAlimenticio(
      titulo: 'Desayuno',
      descripcion: 'Avena con frutas, yogur natural y café descafeinado',
      horario: '7:00 AM',
    ),
    PlanAlimenticio(
      titulo: 'Almuerzo',
      descripcion: 'Ensalada de pollo, quinoa y vegetales al vapor',
      horario: '12:30 PM',
    ),
    PlanAlimenticio(
      titulo: 'Cena',
      descripcion: 'Pescado a la plancha con espárragos y batata asada',
      horario: '7:00 PM',
    ),
    PlanAlimenticio(
      titulo: 'Snack',
      descripcion: 'Nueces y manzana',
      horario: '4:00 PM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planes Alimenticios'),
      ),
      body: ListView.builder(
        itemCount: planes.length,
        itemBuilder: (context, index) {
          final plan = planes[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.restaurant_menu, color: Colors.blue, size: 40),
              title: Text(
                plan.titulo,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.descripcion),
                  SizedBox(height: 4),
                  Text(
                    'Hora: ${plan.horario}',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Aquí puedes definir la acción al seleccionar un plan
              },
            ),
          );
        },
      ),
    );
  }
}
