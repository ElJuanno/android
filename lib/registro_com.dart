import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MonitoreoComidasPage extends StatefulWidget {
  const MonitoreoComidasPage({super.key});
  @override
  State<MonitoreoComidasPage> createState() => _MonitoreoComidasPageState();
}

class _MonitoreoComidasPageState extends State<MonitoreoComidasPage> {
  // Paleta
  static const kPrimary = Color(0xFF00A86B);
  static const kBg = Color(0xFFF6FAF7);
  static const kText = Color(0xFF0E3A2D);

  Future<Map<String, dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = ApiService.I.comidasIndex(limit: 200);
    setState(() {});
  }

  // --------- helpers ----------
  static List<num> _nums(dynamic v) => (v is List)
      ? v.map((e) => (e is num) ? e : num.tryParse('$e') ?? 0).toList()
      : const <num>[];
  static List<String> _strs(dynamic v) =>
      (v is List) ? v.map((e) => e.toString()).toList() : const <String>[];
  static num _sum(List<num> xs) => xs.fold<num>(0, (a, b) => a + b);
  static String _n(num v, {int p = 1}) =>
      (v == v.roundToDouble()) ? v.toStringAsFixed(0) : v.toStringAsFixed(p);

  static DateTime? _tryParse(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s).toLocal();
    } catch (_) {
      return null;
    }
  }

  static String _fmtDate(String? iso) {
    final d = _tryParse(iso);
    if (d == null) return '';
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  static String _fmtTime(String? isoOrTime) {
    // acepta "HH:mm:ss" o ISO y lo devuelve HH:mm
    final iso = isoOrTime ?? '';
    final parsed = _tryParse(iso);
    final h = parsed?.hour ?? int.tryParse(iso.split(':').first) ?? 0;
    final m = parsed?.minute ?? int.tryParse(iso.split(':').elementAt(1)) ?? 0;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Monitoreo de comidas'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
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

          final data = snap.data ?? const {};
          final series = (data['series'] ?? const {}) as Map<String, dynamic>;
          final labels = _strs(series['labels']);
          final cals = _nums(series['calorias']);
          final sugars = _nums(series['azucar']);
          final carbs = _nums(series['carbohidratos'] ?? series['carbs']);

          final items = (data['items'] as List? ?? const [])
              .map((e) => (e as Map).cast<String, dynamic>())
              .toList();

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Totales + minicharts
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    padding: const EdgeInsets.all(16),
                    decoration: _box(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Semana (totales)',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: kText)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _stat(
                                icon: Icons.local_fire_department_outlined,
                                title: 'Calorías',
                                value: '${_n(_sum(cals))} cal',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _stat(
                                icon: Icons.opacity_outlined,
                                title: 'Azúcar',
                                value: '${_n(_sum(sugars))} g',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _stat(
                                icon: Icons.bubble_chart_outlined,
                                title: 'Carbohidratos',
                                value: '${_n(_sum(carbs))} g',
                              ),
                            ),
                          ],
                        ),
                        if (labels.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          // 3 sparklines alineadas
                          SizedBox(
                            height: 64,
                            child: Row(
                              children: [
                                Expanded(
                                    child:
                                    _MiniChart(values: cals, label: 'Cal')),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: _MiniChart(
                                        values: sugars, label: 'Azúcar')),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: _MiniChart(
                                        values: carbs, label: 'Carbs')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${_fmtDate(labels.first)}  →  ${_fmtDate(labels.last)}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // === NUEVA GRÁFICA PRINCIPAL ===
                if (labels.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                      child: _WeeklyChart(
                        labels: labels,
                        series: {
                          'Calorías': cals.map((e) => e.toDouble()).toList(),
                          'Azúcar': sugars.map((e) => e.toDouble()).toList(),
                          'Carbs': carbs.map((e) => e.toDouble()).toList(),
                        },
                        colors: const {
                          'Calorías': Color(0xFF1E88E5), // azul
                          'Azúcar': Color(0xFFE53935),   // rojo
                          'Carbs' : Color(0xFFF19C00),   // amarillo
                        },
                      ),
                    ),
                  ),

                // Encabezado historial
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    child: Row(
                      children: [
                        const Text('Historial',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: kText)),
                        const Spacer(),
                        Text(
                          '${items.length} registro${items.length == 1 ? '' : 's'}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ),

                if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _empty('Aún no hay registros esta semana.'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final m = items[i];
                        final id = int.tryParse('${m['id']}') ?? -1;

                        return Dismissible(
                          key: ValueKey('seg-$id-$i'),
                          direction: DismissDirection.endToStart,
                          background: _swipeBg(),
                          confirmDismiss: (_) => _confirmDelete(context),
                          onDismissed: (_) async {
                            final ok = await _delete(id);
                            if (!ok) _reload();
                          },
                          child: _SeguimientoCard(
                            m: m,
                            onDelete: id > 0
                                ? () async {
                              final okAsk = await _confirmDelete(context);
                              if (!okAsk) return;
                              await _delete(id);
                            }
                                : null,
                          ),
                        );
                      },
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 22)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ----- UI helpers -----
  static BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.green.shade100),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.05),
        blurRadius: 14,
        offset: const Offset(0, 8),
      )
    ],
  );

  static Widget _stat(
      {required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: kPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 2),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16, color: kText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _empty(String msg) => Container(
    margin: const EdgeInsets.only(top: 12, bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: _box(),
    child: Center(
      child: Text(msg,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
          textAlign: TextAlign.center),
    ),
  );

  Widget _swipeBg() => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.red.shade100),
    ),
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(Icons.delete_forever_rounded, color: Colors.red.shade400),
        const SizedBox(width: 6),
        Text('Eliminar',
            style: TextStyle(
                color: Colors.red.shade400, fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar registro'),
        content:
        const Text('Esta acción no se puede deshacer. ¿Deseas continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<bool> _delete(int id) async {
    try {
      await ApiService.I.comidasDelete(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registro eliminado'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _reload();
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo eliminar: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }
}

/* ===================== Card de seguimiento ===================== */

class _SeguimientoCard extends StatelessWidget {
  const _SeguimientoCard({required this.m, this.onDelete});
  final Map<String, dynamic> m;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final nombre = (m['nombre'] ?? '').toString();
    final tiempo = (m['tiempo'] ?? '').toString();
    final fecha = _MonitoreoComidasPageState._fmtDate(m['fecha']?.toString());
    final hora = _MonitoreoComidasPageState._fmtTime(m['hora']?.toString());

    String n(dynamic v) {
      final x = (v is num) ? v : num.tryParse('$v') ?? 0;
      return _MonitoreoComidasPageState._n(x);
    }

    return Container(
      decoration: _MonitoreoComidasPageState._box(),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: _MonitoreoComidasPageState.kText),
                ),
              ),
              const SizedBox(width: 8),
              Text('$fecha  $hora',
                  style: TextStyle(color: Colors.grey.shade600)),
              if (onDelete != null) ...[
                const SizedBox(width: 2),
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 22),
                  color: Colors.red.shade400,
                  splashRadius: 20,
                ),
              ]
            ],
          ),
          if (tiempo.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _MonitoreoComidasPageState.kPrimary.withOpacity(.10),
                borderRadius: BorderRadius.circular(999),
                border:
                Border.all(color: _MonitoreoComidasPageState.kPrimary),
              ),
              child: Text(tiempo,
                  style: const TextStyle(
                      color: _MonitoreoComidasPageState.kPrimary,
                      fontWeight: FontWeight.w700)),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _metric(Icons.local_fire_department_outlined,
                  '${n(m["calorias"])} cal'),
              _metric(Icons.opacity_outlined, '${n(m["azucar"])} g'),
              _metric(Icons.bubble_chart_outlined,
                  '${n(m["carbohidratos"])} g'),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _metric(IconData icon, String text) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.black87)),
      ],
    ),
  );
}

/* ===================== Sparkline reutilizable ===================== */

class _MiniChart extends StatelessWidget {
  const _MiniChart({required this.values, required this.label});
  final List<num> values;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
              TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Expanded(
            child: CustomPaint(
              painter: _SparklinePainter(values.map((e) => e.toDouble()).toList(),
                  color: _MonitoreoComidasPageState.kPrimary),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values, {required this.color});
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fill = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(.25), color.withOpacity(0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // área
    final area = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(area, fill);
    // línea
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

/* ===================== Gráfica principal semanal ===================== */

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({
    required this.labels,
    required this.series,
    required this.colors,
  });

  /// Fechas (ISO o texto simple) — se usan sólo para ticks (primer/último)
  final List<String> labels;

  /// Mapa: nombreSerie -> lista de valores
  final Map<String, List<double>> series;

  /// Mapa: nombreSerie -> color
  final Map<String, Color> colors;

  @override
  Widget build(BuildContext context) {
    final height = 220.0;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          children: [
            // leyenda
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: series.keys.map((k) {
                final c = colors[k] ?? Colors.blueGrey;
                return Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
                ]);
              }).toList(),
            ),
            const SizedBox(height: 8),
            // chart
            Expanded(
              child: CustomPaint(
                painter: _LineChartPainter(
                  series: series,
                  colors: colors,
                  gridColor: Colors.grey.shade300,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 6),
            // eje X (solo extremos para no saturar)
            Row(
              children: [
                Text(_MonitoreoComidasPageState._fmtDate(labels.isNotEmpty ? labels.first : ''),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const Spacer(),
                Text(_MonitoreoComidasPageState._fmtDate(labels.isNotEmpty ? labels.last : ''),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.colors,
    required this.gridColor,
  });

  final Map<String, List<double>> series;
  final Map<String, Color> colors;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    // margencitos internos
    const left = 6.0, top = 6.0, right = 6.0, bottom = 6.0;
    final w = size.width - left - right;
    final h = size.height - top - bottom;

    // rango global
    double minV = double.infinity, maxV = -double.infinity;
    for (final xs in series.values) {
      if (xs.isEmpty) continue;
      minV = xs.fold(minV, (a, b) => b < a ? b : a);
      maxV = xs.fold(maxV, (a, b) => b > a ? b : a);
    }
    if (!minV.isFinite || !maxV.isFinite) return;
    if ((maxV - minV).abs() < 1e-6) {
      // evita división por cero
      maxV = minV + 1;
    }

    // grid horizontal (4 líneas)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = top + h * (i / 4);
      canvas.drawLine(Offset(left, y), Offset(left + w, y), gridPaint);
    }

    // cada serie
    for (final entry in series.entries) {
      final name = entry.key;
      final xs = entry.value;
      if (xs.isEmpty) continue;

      final c = colors[name] ?? Colors.blueGrey;

      final path = Path();
      for (var i = 0; i < xs.length; i++) {
        final x = left + (xs.length == 1 ? 0 : i / (xs.length - 1) * w);
        final y = top + (1 - (xs[i] - minV) / (maxV - minV)) * h;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      // área sutil
      final area = Path.from(path)
        ..lineTo(left + w, top + h)
        ..lineTo(left, top + h)
        ..close();
      final fill = Paint()
        ..shader = LinearGradient(
          colors: [c.withOpacity(.18), c.withOpacity(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(left, top, w, h))
        ..style = PaintingStyle.fill;
      canvas.drawPath(area, fill);

      // línea
      final stroke = Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, stroke);

      // puntos
      final dot = Paint()..color = c;
      for (var i = 0; i < xs.length; i++) {
        final x = left + (xs.length == 1 ? 0 : i / (xs.length - 1) * w);
        final y = top + (1 - (xs[i] - minV) / (maxV - minV)) * h;
        canvas.drawCircle(Offset(x, y), 2, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.series != series || oldDelegate.colors != colors;
}
