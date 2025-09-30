import 'package:flutter/material.dart';
// 👇 ajusta la ruta según tu proyecto
import 'package:pru/services/api_service.dart';
import 'package:pru/login.dart'; // solo si prefieres navegar con MaterialPageRoute

class HomeMobilePage extends StatelessWidget {
  const HomeMobilePage({super.key});

  // Paleta Dietali
  static const Color kPrimary = Color(0xFF00A86B);
  static const Color kBg      = Color(0xFFF0F7F3);
  static const Color kText    = Color(0xFF103B2D);

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que deseas cerrar tu sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cerrar sesión')),
        ],
      ),
    ) ?? false;

    if (!ok) return;

    try {
      await ApiService.I.logout();
      // 👉 Opción A: usando ruta nombrada (recomendada)
      //final pushed = Navigator.canPop(context);
      // intenta llevarte a '/login' limpiando el historial
      //Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);

      // 👉 Opción B (si no tienes '/login' en routes), comenta la A y usa esta:
       Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
         (_) => false,
       );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo cerrar sesión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.white24,
              ),
              alignment: Alignment.center,
              child: const Text('D',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            const Text('Dietali', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          // Avatar (opcional)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
          // Menú con Cerrar sesión
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'logout') _logout(context);
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              _WelcomeCard(),
              const SizedBox(height: 12),

              _GridTwoByTwo(children: [
                _FeatureTile(
                  icon: Icons.soup_kitchen_outlined,
                  title: 'Recetas',
                  subtitle: 'Explora recetas para seguir y personalizar.',
                  onTap: () => Navigator.pushNamed(context, '/recetas'),
                ),
                _FeatureTile(
                  icon: Icons.calendar_month_outlined,
                  title: 'Planes por semana',
                  subtitle: 'Tu plan semanal de comidas.',
                  onTap: () => Navigator.pushNamed(context, '/planes'),
                ),
                _FeatureTile(
                  icon: Icons.water_drop_outlined,
                  title: 'Registro de Glucosa',
                  subtitle: 'Registra y consulta tus niveles.',
                  onTap: () => Navigator.pushNamed(context, '/glucosa'),
                ),
                _FeatureTile(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Alergias',
                  subtitle: 'Administra tus alergias.',
                  onTap: () => Navigator.pushNamed(context, '/alergias'),
                ),
              ]),

              const SizedBox(height: 12),

              _FullWidthTile(
                icon: Icons.apple_outlined,
                title: 'Registro de Comidas',
                subtitle: 'Lleva el control de los alimentos consumidos.',
                onTap: () => Navigator.pushNamed(context, '/comidas'),
              ),

              const SizedBox(height: 12),

              _FullWidthTile(
                icon: Icons.monitor_heart_outlined,
                title: 'Medidas de Salud',
                subtitle: 'Consulta tus métricas y evolución.',
                onTap: () => Navigator.pushNamed(context, '/salud'),
              ),
              _FullWidthTile(
                icon: Icons.local_hospital_outlined,
                title: 'Medicos',
                subtitle: 'Consulta un Especialista',
                onTap: () => Navigator.pushNamed(context, '/medicos'),
              ),

              const SizedBox(height: 12),
              _TipsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// ====== Widgets auxiliares (sin cambios de lógica) ======
class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 16, offset: const Offset(0, 8), color: Colors.black.withOpacity(0.06))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        children: [
          Text('¡Bienvenido!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: HomeMobilePage.kText)),
          SizedBox(height: 10),
          Icon(Icons.restaurant_menu, color: HomeMobilePage.kPrimary, size: 36),
          SizedBox(height: 8),
          Text(
            'Plan Alimenticio\nVisualiza y sigue tu plan personalizado.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.25, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _GridTwoByTwo extends StatelessWidget {
  const _GridTwoByTwo({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth;
      final isTiny = width < 360;

      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isTiny ? 0.95 : 1.0,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: children,
      );
    });
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.05),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              Icon(icon, size: 34, color: HomeMobilePage.kPrimary),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: HomeMobilePage.kText,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullWidthTile extends StatelessWidget {
  const _FullWidthTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(blurRadius: 14, offset: const Offset(0, 8), color: Colors.black.withOpacity(0.05))],
          ),
          child: Row(
            children: [
              Icon(icon, size: 34, color: HomeMobilePage.kPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800, color: HomeMobilePage.kText)),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.25),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(blurRadius: 14, offset: const Offset(0, 8), color: Colors.black.withOpacity(0.05))],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, color: HomeMobilePage.kPrimary, size: 30),
          SizedBox(height: 8),
          Text('Sugerencias',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: HomeMobilePage.kText)),
          SizedBox(height: 6),
          Text(
            'Agrega una fruta o verdura extra hoy y ¡mantente hidratado! 🍎🥒💧',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
