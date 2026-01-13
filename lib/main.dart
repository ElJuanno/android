// lib/main.dart
import 'package:flutter/material.dart';

// Tu Home
import 'package:pru/General.dart';
import 'package:pru/Login.dart';

// Páginas ya creadas o por crear
import 'package:pru/Recetas.dart';
import 'package:pru/planes.dart';
import 'package:pru/glucosa.dart';
import 'package:pru/Alergias.dart';
import 'package:pru/registro_com.dart';// <-- ya te la pasé
import 'package:pru/medidas.dart';// <-- ya te la pasé
import 'package:pru/medicos_page.dart';// <-- ya te la pasé

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DietaliApp());
}

class DietaliApp extends StatelessWidget {
  const DietaliApp({super.key});

  // Paleta global
  static const Color kPrimary = Color(0xFF00A86B);
  static const Color kBg      = Color(0xFFF0F7F3);
  static const Color kText    = Color(0xFF103B2D);

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: kPrimary,
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dietali',
      theme: ThemeData(
        colorScheme: scheme,
        primaryColor: kPrimary,
        scaffoldBackgroundColor: kBg,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),

      // Home
      home: const LoginPage(),

      // Rutas nombradas
      routes: {
        '/recetas': (_) => const RecetasPage(),
        '/planes' : (_) => const PlanSemanalPage(),
        '/glucosa': (_) => const GlucosaPage(),
        '/alergias': (_) => const AlergiasPage(),
        '/comidas': (_) => const MonitoreoComidasPage(),
        '/salud'  : (_) => const SaludPage(),
        '/medicos'  : (_) => const MedicosPage(),
        '/login'  : (_) => const LoginPage(),
        
        // Nota: “Sugerencias” no tiene interacción, así que no hay ruta.
      },

      // Por si navegan a algo desconocido
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => _UnknownRouteScreen(name: settings.name ?? ''),
      ),
    );
  }
}

/// Pantalla temporal para las rutas que aún construiremos.
/// Sustitúyela cuando tengamos la implementación real.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\n(próximamente)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DietaliApp.kText,
          ),
        ),
      ),
    );
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ruta no encontrada')),
      body: Center(
        child: Text(
          'No existe la ruta:\n$name',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
