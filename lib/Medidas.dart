import 'package:flutter/material.dart';
import 'services/api_service.dart';

class SaludPage extends StatefulWidget {
  const SaludPage({super.key});
  @override
  State<SaludPage> createState() => _SaludPageState();
}

class _SaludPageState extends State<SaludPage> {
  static const kPrimary = Color(0xFF00A86B);
  static const kBg = Color(0xFFF0F7F3);
  static const kText = Color(0xFF103B2D);

  late Future<_SaludData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SaludData> _load() async {
    final resumen = await ApiService.I.saludResumen();
    final series = await ApiService.I.saludSeries(days: 30);

    final items = <_HistItem>[];
    final lbls = (series['labels'] as List?) ?? const [];
    final g = (series['glucosa'] as List?) ?? const [];
    final fc = (series['fc'] as List?) ?? const [];
    final sys = (series['sys'] as List?) ?? const [];
    final dia = (series['dia'] as List?) ?? const [];

    for (var i = 0; i < lbls.length; i++) {
      DateTime? f;
      final raw = lbls[i];
      if (raw is String) f = DateTime.tryParse(raw);
      if (f == null && raw is num) {
        f = DateTime.fromMillisecondsSinceEpoch(raw.toInt());
      }
      f ??= DateTime.now();

      items.add(_HistItem(
        fecha: f,
        glucosa: _toDouble(g, i),
        frecuencia: _toDouble(fc, i),
        presion: _bpText(_toDouble(sys, i), _toDouble(dia, i)),
      ));
    }
    items.sort((a, b) => b.fecha.compareTo(a.fecha));

    return _SaludData(
      glucosa: _toNum(resumen['glucosa']),
      presion: (resumen['presion'] ?? '').toString(),
      frecuencia: _toNum(resumen['frecuencia']),
      imc: _toNum(resumen['imc']),
      fecha: DateTime.tryParse('${resumen['fecha'] ?? ''}'),
      historial: items,
      // series crudas para graficar
      sGlucosa: g.map((e) => double.tryParse('$e') ?? 0).toList(),
      sFC: fc.map((e) => double.tryParse('$e') ?? 0).toList(),
      sSys: sys.map((e) => double.tryParse('$e') ?? 0).toList(),
      sDia: dia.map((e) => double.tryParse('$e') ?? 0).toList(),
    );
  }

  static double? _toNum(dynamic v) {
    if (v == null) return null;
    return double.tryParse(v.toString());
  }

  static double? _toDouble(List list, int i) {
    if (i >= list.length) return null;
    return double.tryParse('${list[i]}');
  }

  static String? _bpText(double? s, double? d) {
    if (s == null || d == null || (s == 0 && d == 0)) return null;
    return '${s.toStringAsFixed(0)}/${d.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Mi salud'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _future = _load()),
          ),
        ],
      ),
      body: FutureBuilder<_SaludData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const _Loading();
          }
          if (snap.hasError) {
            return _ErrorView(
              error: snap.error.toString(),
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final d = snap.data!;
          final gridCards = [
            _StatCard(
              title: 'Glucosa (mg/dL)',
              value: d.glucosa != null ? d.glucosa!.toStringAsFixed(0) : '—',
              icon: Icons.bloodtype_outlined,
              gradient: const [Color(0xFFDEF7F7), Color(0xFFC8F3E3)],
              badge: d.fecha != null ? _fmtShort(d.fecha!) : null,
            ),
            _StatCard(
              title: 'Presión arterial',
              value: d.presion.isNotEmpty ? d.presion : '—',
              icon: Icons.favorite_outline,
              gradient: const [Color(0xFFEAF2FF), Color(0xFFDDEBFF)],
            ),
            _StatCard(
              title: 'Frecuencia (lpm)',
              value: d.frecuencia != null ? d.frecuencia!.toStringAsFixed(0) : '—',
              icon: Icons.monitor_heart_outlined,
              gradient: const [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
            ),
            _StatCard(
              title: 'IMC',
              value: d.imc != null ? d.imc!.toStringAsFixed(1) : '—',
              icon: Icons.monitor_weight_outlined,
              gradient: const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            ),
          ];

          return RefreshIndicator(
            color: kPrimary,
            onRefresh: () async => setState(() => _future = _load()),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _Grid2(gridCards: gridCards),
                ),

                // ====== BLOQUES DE GRÁFICA ======
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ChartCard(
                    title: 'Glucosa y FC (últimos 30)',
                    leftLabel: 'Glucosa',
                    rightLabel: 'FC',
                    leftColor: const Color(0xFF00A86B),
                    rightColor: const Color(0xFF0077CC),
                    leftValues: d.sGlucosa,
                    rightValues: d.sFC,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ChartCard(
                    title: 'Presión arterial',
                    leftLabel: 'Sistólica',
                    rightLabel: 'Diastólica',
                    leftColor: const Color(0xFFE67E22),
                    rightColor: const Color(0xFF9B59B6),
                    leftValues: d.sSys,
                    rightValues: d.sDia,
                  ),
                ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('Historial',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: kText)),
                      const SizedBox(width: 10),
                      _chip('${d.historial.length} registros'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (d.historial.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _emptyCard('Aún no hay registros.'),
                  )
                else
                  ...d.historial.map((h) => Padding(
                    padding:
                    const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    child: _HistoryTile(item: h),
                  )),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _chip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: kPrimary.withOpacity(.10),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: kPrimary),
    ),
    child: Text(t,
        style: const TextStyle(
            color: kPrimary, fontWeight: FontWeight.w700)),
  );

  Widget _emptyCard(String msg) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _box(),
    child: Center(
        child: Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54))),
  );

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey.shade200),
    boxShadow: [
      BoxShadow(
          blurRadius: 14,
          offset: const Offset(0, 8),
          color: Colors.black.withOpacity(.05)),
    ],
  );

  // ======= formateador de fecha en español sin intl =======
  static const _mes = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
  ];
  static const _dow = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

  static String _fmtShort(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')} ${_mes[d.month - 1]}';
    // corto
  }

  static String fmtLong(DateTime d) {
    final wd = _dow[(d.weekday % 7)];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$wd ${d.day} ${_mes[d.month - 1]} ${d.year} – $hh:$mm';
  }
}

/* ===================== UI widgets ===================== */

class _Grid2 extends StatelessWidget {
  const _Grid2({required this.gridCards});
  final List<Widget> gridCards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 640 ? 3 : 2;
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: gridCards,
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.badge,
  });

  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.8), width: 2),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(.04),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: const Color(0xFF246B52)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: _Colors.kText),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: const Border.fromBorderSide(
                          BorderSide(color: Color(0xFF00A86B))),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF00A86B),
                          fontWeight: FontWeight.w700),
                    ),
                  ),
              ]),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 34,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                    color: _Colors.kText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ======= Tarjeta con 2 líneas (sparkline) ======= */

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftValues,
    required this.rightValues,
    required this.leftColor,
    required this.rightColor,
  });

  final String title, leftLabel, rightLabel;
  final List<double> leftValues, rightValues;
  final Color leftColor, rightColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: _Colors.kText, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _DualSparklinePainter(
                leftValues: leftValues,
                rightValues: rightValues,
                leftColor: leftColor,
                rightColor: rightColor,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _legendDot(leftColor, leftLabel),
              const SizedBox(width: 16),
              _legendDot(rightColor, rightLabel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color c, String t) => Row(
    children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(t, style: TextStyle(color: Colors.grey.shade700)),
    ],
  );
}
/* ======= Fila de historial (pill chips) ======= */

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});
  final _HistItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _SaludPageState.fmtLong(item.fecha),
              style: const TextStyle(
                color: _Colors.kText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (item.glucosa != null)
                  _pill('Glucosa: ${item.glucosa!.toStringAsFixed(0)}'),
                if (item.frecuencia != null)
                  _pill('FC: ${item.frecuencia!.toStringAsFixed(0)}'),
                if (item.presion != null) _pill('PA: ${item.presion}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _pill(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Text(t, style: const TextStyle(color: Colors.black87)),
  );
}

/* ======= Painters ======= */

class _DualSparklinePainter extends CustomPainter {
  _DualSparklinePainter({
    required this.leftValues,
    required this.rightValues,
    required this.leftColor,
    required this.rightColor,
  });

  final List<double> leftValues, rightValues;
  final Color leftColor, rightColor;

  @override
  void paint(Canvas canvas, Size size) {
    void draw(List<double> values, Color color) {
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
      canvas.drawPath(path, stroke);
    }

    draw(leftValues, leftColor);
    draw(rightValues, rightColor);
  }

  @override
  bool shouldRepaint(covariant _DualSparklinePainter oldDelegate) =>
      oldDelegate.leftValues != leftValues ||
          oldDelegate.rightValues != rightValues ||
          oldDelegate.leftColor != leftColor ||
          oldDelegate.rightColor != rightColor;
}

/* ===================== modelos locales ===================== */

class _SaludData {
  final double? glucosa;
  final String presion;
  final double? frecuencia;
  final double? imc;
  final DateTime? fecha;
  final List<_HistItem> historial;

  // series
  final List<double> sGlucosa, sFC, sSys, sDia;

  _SaludData({
    required this.glucosa,
    required this.presion,
    required this.frecuencia,
    required this.imc,
    required this.fecha,
    required this.historial,
    required this.sGlucosa,
    required this.sFC,
    required this.sSys,
    required this.sDia,
  });
}

class _HistItem {
  final DateTime fecha;
  final double? glucosa;
  final double? frecuencia;
  final String? presion;
  _HistItem({
    required this.fecha,
    this.glucosa,
    this.frecuencia,
    this.presion,
  });
}

class _Colors {
  static const kText = Color(0xFF103B2D);
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text('Error: $error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
