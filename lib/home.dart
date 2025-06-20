import 'package:flutter/material.dart';
import 'services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final String nombreUsuario;
  const HomeScreen({super.key, required this.nombreUsuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 10),
            const Text(
              'Dietali',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.dashboard, color: Colors.white),
          ),
          PopupMenuButton<String>(
            icon: Row(
              children: [
                const Icon(Icons.person, color: Colors.white),
                const SizedBox(width: 6),
                Text(widget.nombreUsuario.toUpperCase(),
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
            onSelected: (value) async {
              if (value == 'perfil') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'logout') {
                await ApiService.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'perfil', child: Text('Ver perfil')),
              const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '¡Hola, ${widget.nombreUsuario.toUpperCase()}!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.green.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCard(Icons.restaurant_menu_rounded, 'Plan Alimenticio', 'Visualiza y sigue tu plan alimenticio personalizado.', 'Ver plan', () {
                  Navigator.pushNamed(context, '/plan');
                }),
                _buildCard(Icons.bloodtype_rounded, 'Registro de Glucosa', 'Registra y consulta tus niveles de glucosa.', 'Registrar', () {
                  Navigator.pushNamed(context, '/medidas');
                }),
                _buildCard(Icons.warning_amber_rounded, 'Alergias', 'Administra tus alergias alimentarias.', 'Gestionar', () {}),
                _buildCard(Icons.fastfood_rounded, 'Comidas', 'Lleva el control de alimentos consumidos.', 'Registrar', () {
                  Navigator.pushNamed(context, '/seguimiento');
                }),
                _buildCard(Icons.monitor_heart_rounded, 'Medidas de Salud', 'Consulta tus últimas medidas y evolución.', 'Ver salud', () {}),
              ],
            ),
            const SizedBox(height: 30),
            _buildConsejoDelDia(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, String subtitle, String buttonText, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 50, color: Colors.green.shade700),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(buttonText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildConsejoDelDia() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade200, Colors.green.shade50]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.lightbulb_rounded, size: 40, color: Colors.green.shade700),
          const SizedBox(height: 10),
          Text(
            'Consejo del día',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega una fruta o verdura extra hoy y ¡mantente hidratado! 🍓🥦💧',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
