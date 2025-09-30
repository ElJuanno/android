import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../model/recipe_item.dart';

class RecetasPage extends StatefulWidget {
  const RecetasPage({super.key});
  @override
  State<RecetasPage> createState() => _RecetasPageState();
}

class _RecetasPageState extends State<RecetasPage> {
  Future<Map<String, dynamic>>? _future;

  static const kPrimary = Color(0xFF00A86B);
  static const kBg = Color(0xFFF0F7F3);
  static const kText = Color(0xFF103B2D);

  @override
  void initState() {
    super.initState();
    _future = ApiService.I.planRecetas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Recetas'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snap.error}', textAlign: TextAlign.center),
              ),
            );
          }

          final data = snap.data!;
          final agrupadas = (data['agrupadas'] ?? {}) as Map<String, dynamic>;
          final imc = data['imc'];
          final glu = data['glucosa'];
          final grupos = agrupadas.entries.toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Encabezado
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                        color: Colors.black.withOpacity(.06),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Recetas',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: kText)),
                            SizedBox(height: 4),
                            Text('Visualiza las recetas que puedes seguir y personalizar.'),
                          ],
                        ),
                      ),
                      if (imc != null) _badge('IMC: $imc'),
                      const SizedBox(width: 8),
                      if (glu != null) _badge('Glucosa: $glu'),
                    ],
                  ),
                ),
              ),

              // Grupos
              for (final entry in grupos) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Text(entry.key,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kText)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemBuilder: (_, i) {
                      final raw = (entry.value as List)[i] as Map<String, dynamic>;
                      final r = RecipeItem.fromJson(raw);
                      return _RecipeCard(item: r);
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: (entry.value as List).length,
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  static Widget _badge(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: kPrimary.withOpacity(.10),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: kPrimary),
    ),
    child: Text(t,
        style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
  );
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.item});
  final RecipeItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTiny = MediaQuery.of(context).size.width < 360;

    num _parseNum(dynamic v) {
      if (v is num) return v;
      return num.tryParse(v?.toString() ?? '') ?? 0;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {}, // si quieres abrir detalle
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade100),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(.04),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chips + avatar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _avatarCircle(_emojiForCategory(item.categoria)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(item.categoria, filled: true),
                        _chip(item.color),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Título
              Text(
                item.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _RecetasColors.kText,
                ),
              ),
              const SizedBox(height: 6),

              // Ingredientes
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.list_alt_outlined, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.ingredientes,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700, height: 1.25),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Métricas como pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _metricPill('🔥 ${item.calorias} cal'),
                  _metricPill('💧 ${item.azucar} azúcar'),
                  _metricPill('🫧 ${item.carbohidratos} carbs'),
                ],
              ),

              const SizedBox(height: 12),

              // Botón a TODO el ancho (adiós overflow)
              SizedBox(
                width: double.infinity,
                height: isTiny ? 40 : 44,
                child: ElevatedButton.icon(
                    onPressed: () async {
                      num _n(dynamic v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;

                      try {
                        await ApiService.I.comidasCreate(
                          nombre: item.nombre,
                          calorias: _n(item.calorias),
                          azucar: _n(item.azucar),
                          carbohidratos: _n(item.carbohidratos),  // <- usa campo correcto
                          momento: item.categoria,                // si tu backend lo guarda como 'horario'
                          recetaId: (item.id > 0) ? item.id : null,
                          fecha: DateTime.now(),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Añadido al monitoreo')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar: $e')),
                          );
                        }
                      }
                    },
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Seguir'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _RecetasColors.kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _chip(String text, {bool filled = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: filled ? _RecetasColors.kPrimary.withOpacity(.10) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: _RecetasColors.kPrimary),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: _RecetasColors.kPrimary,
        fontWeight: filled ? FontWeight.w700 : FontWeight.w600,
      ),
    ),
  );

  static Widget _metricPill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Text(text, style: const TextStyle(color: Colors.black87)),
  );

  static Widget _avatarCircle(String emoji) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: _RecetasColors.kPrimary.withOpacity(.12),
      shape: BoxShape.circle,
      border: Border.all(color: _RecetasColors.kPrimary.withOpacity(.25)),
    ),
    alignment: Alignment.center,
    child: Text(emoji, style: const TextStyle(fontSize: 18)),
  );

  static String _emojiForCategory(String c) {
    final s = c.toLowerCase();
    if (s.contains('breakfast') || s.contains('desay')) return '🍳';
    if (s.contains('lunch') || s.contains('snack') || s.contains('almuerzo')) return '🥪';
    if (s.contains('dinner') || s.contains('cena')) return '🍝';
    if (s.contains('salad')) return '🥗';
    return '🍽️';
  }
}

class _RecetasColors {
  static const kPrimary = Color(0xFF00A86B);
  static const kText = Color(0xFF103B2D);
}
