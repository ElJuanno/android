import 'package:flutter/material.dart';
import 'planes.dart';
import 'profile.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Alimenticio Diabetes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green[50],
        appBarTheme: AppBarTheme(backgroundColor: Colors.green[700]),
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
                color: Colors.green[700],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle, color: Colors.white, size: 48),
                  SizedBox(height: 10),
                  Text(
                    'Menú Principal',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.green[800]),
              title: Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.restaurant_menu, color: Colors.green[800]),
              title: Text('Plan Alimenticio'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlanesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.note_add, color: Colors.green[800]),
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
            Text(
              'Selecciona una opción para comenzar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green[800]),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.restaurant_menu, color: Colors.green[600], size: 40),
                title: Text('Plan Alimenticio'),
                subtitle: Text('Visualiza y sigue tu plan alimenticio'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlanesScreen()),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.healing, color: Colors.green[600], size: 40),
                title: Text('Registro de Glucosa'),
                subtitle: Text('Registra tus niveles de glucosa'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navegar a la sección de registro de glucosa
                },
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.note_add, color: Colors.green[600], size: 40),
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
