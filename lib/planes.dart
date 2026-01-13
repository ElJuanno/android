import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../model/recipe_item.dart';

class PlanSemanalPage extends StatefulWidget {
  const PlanSemanalPage({super.key});

  @override
  State<PlanSemanalPage> createState() => _PlanSemanalPageState();
}

class _PlanSemanalPageState extends State<PlanSemanalPage> {
  // Paleta
  static const kPrimary = Color(0xFF00A86B);
  static const kBg = Color(0xFFF0F7F3);
  static const kText = Color(0xFF103B2D);

  static const List<String> kTiempos = ['Desayuno', 'Comida', 'Cena', 'Snack'];

  Future<Map<String, dynamic>>? _future;
  int _diaIndex = 0; // 0..6

  @override
  void initState() {
    super.initState();
    // Usamos la MISMA API que Recetas (dataset/api_flask detrás)
    _future = ApiService.I.planRecetas(); // modo: 'agrupadas'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Plan semanal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _diaIndex = 0;
              _future = ApiService.I.planRecetas();
            }),
          ),
        ],
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

          final data = snap.data ?? {};
          final agrupadas = (data['agrupadas'] ?? data['recetas'] ?? {}) as Map<String, dynamic>;
          final imc = data['imc'];
          final glu = data['glucosa'];

          // 1) Aplana todas las recetas de "agrupadas" en una sola lista
          final flat = _flattenAgrupadas(agrupadas);

          // 2) Construye 7 días tomando SOLO recetas del bucket correcto
          final dias = _buildWeekFromFlat(flat, days: 7);

          // 3) Día seleccionado
          final day = dias.isNotEmpty
              ? dias[_diaIndex.clamp(0, dias.length - 1)]
              : <String, List<RecipeItemPlus>>{for (final t in kTiempos) t: <RecipeItemPlus>[]};

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Encabezado (Wrap para evitar overflow)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: _box(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bienvenido a tu plan',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _pillButton('Recetas', onTap: () {
                            Navigator.pushNamed(context, '/recetas');
                          }),
                          _pillSelected('Semanal'),
                          if (imc != null) _badge('IMC: $imc'),
                          if (glu != null) _badge('Glucosa: $glu'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Selector de días
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Text('Selecciona un día',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) {
                      final selected = i == _diaIndex;
                      return ChoiceChip(
                        label: Text('Día ${i + 1}'),
                        selected: selected,
                        onSelected: (_) => setState(() => _diaIndex = i),
                        selectedColor: kPrimary,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : kText,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        ),
                        backgroundColor: Colors.white,
                        shape: StadiumBorder(
                          side: BorderSide(color: selected ? kPrimary : Colors.grey.shade300),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: dias.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Secciones por tiempo
              ...kTiempos.expand((t) {
                final items = day[t] ?? const <RecipeItemPlus>[];
                return <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            t,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kText),
                          ),
                          const SizedBox(width: 8),
                          if (items.isNotEmpty)
                            _badge('${items.length} ${items.length == 1 ? 'receta' : 'recetas'}'),
                        ],
                      ),
                    ),
                  ),
                  if (items.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _emptyCard('Sin recomendaciones para $t.'),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList.separated(
                        itemBuilder: (_, i) => _MealCard(item: items[i]),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: items.length,
                      ),
                    ),
                ];
              }).toList(),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  // ================== CLASIFICACIÓN & AGRUPACIÓN ==================

  /// Devuelve uno de: 'Desayuno' | 'Comida' | 'Cena' | 'Snack'
  String _inferTiempo(Map<String, dynamic> m) {
    String pick(String k) => (m[k] ?? '').toString().toLowerCase().trim();
    final cands = <String>[
      pick('momento'),
      pick('etiqueta'),
      pick('tag'),
      pick('categoria'),
      pick('category'),
      pick('tipo'),
      pick('meal_type'),
    ].where((s) => s.isNotEmpty).toList();

    final text = cands.join(' ');

    if (RegExp(r'\b(desay|breakfast)\b').hasMatch(text)) return 'Desayuno';
    if (RegExp(r'\b(comida|almuer|lunch)\b').hasMatch(text)) return 'Comida';
    if (RegExp(r'\b(cena|dinner|supper)\b').hasMatch(text)) return 'Cena';
    if (RegExp(r'\b(snack|colaci|colación)\b').hasMatch(text)) return 'Snack';

    // Heurísticas por palabras comunes
    if (text.contains('salad') || text.contains('ensalada')) return 'Comida';
    if (text.contains('soup') || text.contains('sopa')) return 'Comida';
    if (text.contains('pasta') || text.contains('arroz')) return 'Cena';
    if (text.contains('dessert') || text.contains('postre')) return 'Snack';

    return 'Comida'; // fallback
  }

  /// Aplana el mapa de "agrupadas" a una sola lista de recetas
  List<Map<String, dynamic>> _flattenAgrupadas(Map<String, dynamic> agrupadas) {
    final out = <Map<String, dynamic>>[];
    for (final entry in agrupadas.entries) {
      final list = entry.value;
      if (list is List) {
        for (final e in list) {
          if (e is Map) out.add(e.cast<String, dynamic>());
        }
      }
    }
    return out;
  }

  /// Construye [days] días asignando 1 receta por tiempo por día SOLO del bucket correcto.
  /// Si se acaba un bucket (p. ej. no hay más desayunos), ese tiempo queda vacío ese día.
  List<Map<String, List<RecipeItemPlus>>> _buildWeekFromFlat(
      List<Map<String, dynamic>> flat, {
        int days = 7,
      }) {
    // 1) Clasifica por tiempo
    final buckets = <String, List<Map<String, dynamic>>>{
      for (final t in kTiempos) t: <Map<String, dynamic>>[],
    };
    for (final m in flat) {
      final t = _inferTiempo(m);
      buckets[t]!.add(m);
    }

    // 2) Estructura vacía
    final week = List.generate(days, (_) => <String, List<RecipeItemPlus>>{
      for (final t in kTiempos) t: <RecipeItemPlus>[],
    });

    // 3) Asigna 1 por tiempo por día
    for (var d = 0; d < days; d++) {
      for (final t in kTiempos) {
        final b = buckets[t]!;
        if (b.isEmpty) continue;
        final m = b.removeAt(0);
        final r = RecipeItem.fromJson(m);
        week[d][t]!.add(RecipeItemPlus(base: r, momento: t));
      }
    }

    return week;
  }

  // ================== UI HELPERS ==================

  static Widget _pillSelected(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(999)),
    child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
  );

  static Widget _pillButton(String t, {required VoidCallback onTap}) => InkWell(
    borderRadius: BorderRadius.circular(999),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kPrimary),
      ),
      child: Text(t, style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w800)),
    ),
  );

  static Widget _badge(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: kPrimary.withOpacity(.10),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: kPrimary),
    ),
    child: Text(t, style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
  );
}

/* ---------- Card de comida responsiva ---------- */

class RecipeItemPlus {
  final RecipeItem base;
  final String momento; // Desayuno/Comida/Cena/Snack
  RecipeItemPlus({required this.base, required this.momento});
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.item});
  final RecipeItemPlus item;

  @override
  Widget build(BuildContext context) {
    final r = item.base;

    num _parseNum(dynamic v) {
      if (v is num) return v;
      return num.tryParse(v?.toString() ?? '') ?? 0;
    }

    return Container(
      decoration: _box(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;

            final metricsWrap = Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _metric(Icons.local_fire_department_outlined, '${r.calorias} cal'),
                _metric(Icons.opacity_outlined, '${r.azucar} azúcar'),
                _metric(Icons.bubble_chart_outlined, '${r.carbohidratos} carbs'),
              ],
            );

            final seguirBtn = SizedBox(
              height: 40,
              child: OutlinedButton(
                onPressed: () async {
                  final r = item.base;
                  num _n(dynamic v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;

                  try {
                    await ApiService.I.comidasCreate(
                      nombre: r.nombre,
                      calorias: _n(r.calorias),
                      azucar: _n(r.azucar),
                      carbohidratos: _n(r.carbohidratos),  // <- clave correcta
                      momento: item.momento,
                      recetaId: (r.id > 0) ? r.id : null,
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
                style: OutlinedButton.styleFrom(
                  foregroundColor: _Colors.kPrimary,
                  side: const BorderSide(color: _Colors.kPrimary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Seguir'),
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chips
                Wrap(spacing: 8, runSpacing: 6, children: [
                  if (item.momento.isNotEmpty) _chip(item.momento, filled: true),
                  _chip(r.categoria),
                ]),
                const SizedBox(height: 8),

                // Título
                Text(
                  r.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _Colors.kText),
                ),
                const SizedBox(height: 6),

                // Ingredientes
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.list_alt_outlined, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      r.ingredientes,
                      style: TextStyle(color: Colors.grey.shade700, height: 1.2),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),

                // Métricas + botón (responsivo)
                if (!isNarrow)
                  Row(
                    children: [
                      Expanded(child: metricsWrap),
                      const SizedBox(width: 12),
                      seguirBtn,
                    ],
                  )
                else ...[
                  metricsWrap,
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: seguirBtn),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  static Widget _chip(String text, {bool filled = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: filled ? _Colors.kPrimary.withOpacity(.12) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: _Colors.kPrimary),
    ),
    child: Text(
      text,
      style: TextStyle(color: _Colors.kPrimary, fontWeight: filled ? FontWeight.w700 : FontWeight.w600),
    ),
  );

  static Widget _metric(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: Colors.black54),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(color: Colors.black87)),
    ],
  );
}

/* ---------- estilos comunes ---------- */

class _Colors {
  static const kPrimary = Color(0xFF00A86B);
  static const kText = Color(0xFF103B2D);
}

BoxDecoration _box() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: Colors.grey.shade200),
  boxShadow: [
    BoxShadow(
      blurRadius: 14,
      offset: const Offset(0, 8),
      color: Colors.black.withOpacity(.05),
    ),
  ],
);

/// Card vacía cuando no hay recetas
Widget _emptyCard(String msg) => Container(
  margin: const EdgeInsets.only(top: 12, bottom: 12),
  padding: const EdgeInsets.all(16),
  decoration: _box(),
  child: Center(
    child: Text(
      msg,
      style: const TextStyle(color: Colors.black54, fontSize: 14),
      textAlign: TextAlign.center,
    ),
  ),
);
