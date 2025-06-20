import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'login.dart';
import 'Profile.dart';
import 'Medidas.dart';
import 'package:pru/Seguimiento.dart';
import 'Planes.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  String nombreUsuario = '';

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        final perfil = await ApiService.me();
        if (perfil.containsKey('nombre')) {
          setState(() {
            isLoggedIn = true;
            nombreUsuario = perfil['nombre'];
          });
        }
      } catch (e) {
        setState(() {
          isLoggedIn = false;
          nombreUsuario = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dietali',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(nombreUsuario: 'Usuario'), // Solo si ya tienes el nombre
        '/profile': (context) => ProfileScreen(),
        '/medidas': (context) => MedidasSaludScreen(),
        '/plan': (context) => PlanAlimenticioScreen(), // ← agregas esta línea
        '/seguimiento': (context) => SeguimientoScreen(),
      },

      home: isLoggedIn
          ? HomeScreen(nombreUsuario: nombreUsuario)
          : LoginScreen(),
    );
  }
}
