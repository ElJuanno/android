import 'package:flutter/material.dart';
import 'planes.dart'; // Asegúrate de tener el archivo planes.dart con la clase PlanesScreen

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Alimenticio Diabetes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VistaGeneralScreen(),
    );
  }
}

class VistaGeneralScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vista General'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Acción para notificaciones
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                // Navegar a la sección de perfil
              },
            ),
            ListTile(
              leading: Icon(Icons.restaurant_menu),
              title: Text('Plan Alimenticio'),
              onTap: () {
                // Navegamos a la pantalla de planes alimenticios
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlanesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.note_add),
              title: Text('Registro de Comidas'),
              onTap: () {
                // Navegar a la sección de registro de comidas
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tarjeta de Plan Alimenticio
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.restaurant_menu, color: Colors.blue, size: 40),
                title: Text('Plan Alimenticio'),
                subtitle: Text('Visualiza y sigue tu plan alimenticio'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navegamos a la pantalla de planes alimenticios
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlanesScreen()),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            // Tarjeta de Registro de Glucosa
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.healing, color: Colors.red, size: 40),
                title: Text('Registro de Glucosa'),
                subtitle: Text('Registra tus niveles de glucosa'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navegar a la sección de registro de glucosa
                },
              ),
            ),
            SizedBox(height: 10),
            // Tarjeta de Registro de Comidas
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.note_add, color: Colors.green, size: 40),
                title: Text('Registro de Comidas'),
                subtitle: Text('Registra los alimentos consumidos'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navegar a la sección de registro de comidas
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
