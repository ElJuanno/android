import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../model/recipe_item.dart';

class GlucosaPage extends StatefulWidget {
  const GlucosaPage({super.key});

  @override
  State<GlucosaPage> createState() => _GlucosaPageState();
}

class _GlucosaPageState extends State<GlucosaPage> {
  static const kPrimary = Color(0xFF00A86B);
  static const kBg = Color(0xFFF0F7F3);
  static const kText = Color(0xFF103B2D);

  // Form controllers
  final _glucosaCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _presionCtrl = TextEditingController();
  final _frecuenciaCtrl = TextEditingController();
  String _condicion = 'Ninguna';

  bool _saving = false;

  // Data
  List<GlucosaItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _glucosaCtrl.dispose();
    _edadCtrl.dispose();
    _presionCtrl.dispose();
    _frecuenciaCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.I.glucosaIndex(limit: 120);
      final itemsRaw = (data['items'] as List?) ?? [];
      final items = itemsRaw.map((e) => GlucosaItem.fromJson(e)).toList();

      // Prefill con la última medición (lista viene desc por created_at)
      if (items.isNotEmpty) {
        final last = items.first;
        _glucosaCtrl.text = last.glucosa.toStringAsFixed(0);
        _edadCtrl.text = (last.edad ?? '').toString();
        _presionCtrl.text = last.presion ?? '';
        _frecuenciaCtrl.text =
        last.frecuencia != null ? last.frecuencia!.toStringAsFixed(0) : '';
        _condicion = last.condicion?.isNotEmpty == true ? last.condicion! : 'Ninguna';
      }

      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar: $e')),
      );
    }
  }

  Future<void> _guardar() async {
    final g = double.tryParse(_glucosaCtrl.text.trim());
    final edad = int.tryParse(_edadCtrl.text.trim());
    final frec = _frecuenciaCtrl.text.trim().isEmpty
        ? null
        : double.tryParse(_frecuenciaCtrl.text.trim());
    final presion = _presionCtrl.text.trim().isEmpty ? null : _presionCtrl.text.trim();

    if (g == null || edad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Glucosa y edad son obligatorios')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ApiService.I.glucosaCreate(
        glucosa: g,
        edad: edad,
        presion: presion,
        frecuencia: frec,
        condicion: _condicion == 'Ninguna' ? null : _condicion,
      );

      // Recargar (prefill quedará con lo último guardado)
      await _load();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _eliminar(GlucosaItem it) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text('¿Eliminar medición de ${it.glucosa.toStringAsFixed(0)} mg/dL?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ApiService.I.glucosaDelete(it.id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTiny = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Glucosa'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Encabezado
            _HeaderCard(),

            const SizedBox(height: 12),

            // Formulario (SIN gráfica)
            _FormCard(
              glucosaCtrl: _glucosaCtrl,
              edadCtrl: _edadCtrl,
              presionCtrl: _presionCtrl,
              frecuenciaCtrl: _frecuenciaCtrl,
              condicion: _condicion,
              onCondicionChanged: (v) => setState(() => _condicion = v),
              onGuardar: _saving ? null : _guardar,
              saving: _saving,
              isTiny: isTiny,
            ),

            const SizedBox(height: 16),

            // Historial
            const Text('Historial',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 8),

            ..._items.map((it) => _HistoryTile(item: it, onDelete: () => _eliminar(it))),
          ],
        ),
      ),
    );
  }
}

/* ---------- UI Pieces ---------- */

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  static const kPrimary = Color(0xFF00A86B);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [kPrimary, Color(0xFF118E66)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(blurRadius: 16, offset: Offset(0, 6), color: Colors.black26)],
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: const Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: Colors.white24, child: Icon(Icons.monitor_heart_outlined, color: Colors.white)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Registrar Medidas de Salud',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                SizedBox(height: 4),
                Text('Guarda y actualiza tus parámetros principales', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.glucosaCtrl,
    required this.edadCtrl,
    required this.presionCtrl,
    required this.frecuenciaCtrl,
    required this.condicion,
    required this.onCondicionChanged,
    required this.onGuardar,
    required this.saving,
    required this.isTiny,
  });

  final TextEditingController glucosaCtrl;
  final TextEditingController edadCtrl;
  final TextEditingController presionCtrl;
  final TextEditingController frecuenciaCtrl;
  final String condicion;
  final ValueChanged<String> onCondicionChanged;
  final VoidCallback? onGuardar;
  final bool saving;
  final bool isTiny;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _box(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nueva medición',
              style: TextStyle(fontWeight: FontWeight.w800, color: _Styles.kText)),
          const SizedBox(height: 12),

          // Fila 1: glucosa / edad
          Row(
            children: [
              Expanded(
                child: _input(
                  label: 'Glucosa (mg/dL)',
                  controller: glucosaCtrl,
                  hint: 'Ej. 120',
                  keyboard: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _input(
                  label: 'Edad',
                  controller: edadCtrl,
                  hint: 'Ej. 28',
                  keyboard: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Fila 2: presión / frecuencia
          Row(
            children: [
              Expanded(
                child: _input(
                  label: 'Presión arterial',
                  controller: presionCtrl,
                  hint: 'Ej. 120/80',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _input(
                  label: 'Frecuencia (lpm)',
                  controller: frecuenciaCtrl,
                  hint: 'Ej. 72',
                  keyboard: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Condición
          const Text('Condición', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: condicion,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'Ninguna', child: Text('Ninguna')),
                  DropdownMenuItem(value: 'Diabetes', child: Text('Diabetes')),
                  DropdownMenuItem(value: 'Prediabetes', child: Text('Prediabetes')),
                  DropdownMenuItem(value: 'Hipertensión', child: Text('Hipertensión')),
                ],
                onChanged: (v) => onCondicionChanged(v ?? 'Ninguna'),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: isTiny ? 42 : 46,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGuardar,
              icon: saving
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.save_outlined),
              label: Text(saving ? 'Guardando...' : 'Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _Styles.kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboard,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item, required this.onDelete});
  final GlucosaItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dt = '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')} '
        '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _box(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: _Styles.kPrimary.withOpacity(.12),
          child: const Text('🩸', style: TextStyle(fontSize: 18)),
        ),
        title: Text('${item.glucosa.toStringAsFixed(0)} mg/dL',
            style: const TextStyle(fontWeight: FontWeight.w800, color: _Styles.kText)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dt),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (item.presion != null && item.presion!.isNotEmpty)
                  _pill('🩺 ${item.presion}'),
                if (item.frecuencia != null) _pill('❤️ ${item.frecuencia!.toStringAsFixed(0)} lpm'),
                if (item.condicion != null && item.condicion!.isNotEmpty)
                  _pill('⚑ ${item.condicion}'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }

  Widget _pill(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Text(t),
  );
}

/* ---------- Styles & helpers ---------- */

class _Styles {
  static const kPrimary = Color(0xFF00A86B);
  static const kText = Color(0xFF103B2D);
}

BoxDecoration _box() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: Colors.grey.shade200),
  boxShadow: [
    BoxShadow(blurRadius: 14, offset: const Offset(0, 8), color: Colors.black.withOpacity(.05))
  ],
);
