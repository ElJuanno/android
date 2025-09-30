import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AlergiasPage extends StatefulWidget {
  const AlergiasPage({super.key});
  @override
  State<AlergiasPage> createState() => _AlergiasPageState();
}

class _AlergiasPageState extends State<AlergiasPage> {
  // Paleta
  static const kPrimary = Color(0xFF00A86B);
  static const kBg = Color(0xFFF0F7F3);
  static const kText = Color(0xFF103B2D);

  late Future<void> _future;
  final Set<int> _seleccion = {};
  final TextEditingController _search = TextEditingController();
  bool _saving = false;

  List<Map<String, dynamic>> _catalogo = [];
  List<Map<String, dynamic>> get _filtradas {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _catalogo;
    return _catalogo.where((m) {
      final n = (m['nombre'] ?? m['descripcion'] ?? '').toString().toLowerCase();
      return n.contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<void> _cargar() async {
    final cat = await ApiService.I.alergiasCatalogo(); // [{id, nombre}]
    final mis = await ApiService.I.alergiasMis();      // [ids]
    _catalogo = cat;
    _seleccion
      ..clear()
      ..addAll(mis);
  }

  Future<void> _guardar() async {
    setState(() => _saving = true);
    try {
      await ApiService.I.alergiasGuardar(_seleccion.toList());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alergias guardadas')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _selectAllFiltered() {
    for (final m in _filtradas) {
      _seleccion.add(int.parse(m['id'].toString()));
    }
    setState(() {});
  }

  void _clearFiltered() {
    for (final m in _filtradas) {
      _seleccion.remove(int.parse(m['id'].toString()));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Alergias'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _future = _cargar()),
          ),
        ],
      ),
      body: FutureBuilder<void>(
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

          final total = _catalogo.length;
          final sel = _seleccion.length;

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async => setState(() => _future = _cargar()),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  children: [
                    // Encabezado
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _box(),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alergias',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: kText)),
                          SizedBox(height: 6),
                          Text(
                            'Marca tus alérgenos. Se aplican automáticamente en Recetas y Plan semanal.',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Barra de acciones + contador
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _box(),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _SearchField(
                                  controller: _search,
                                  hint: 'Buscar alergia…',
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _CounterPill(text: '$sel/$total'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _ghostBtn(Icons.done_all, 'Seleccionar todo', onTap: _selectAllFiltered),
                              const SizedBox(width: 8),
                              _ghostBtn(Icons.clear_all, 'Limpiar', onTap: _clearFiltered),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Chips
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _box(),
                      child: _catalogo.isEmpty
                          ? const Text(
                        'Sin alergias en el catálogo.',
                        textAlign: TextAlign.center,
                      )
                          : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _filtradas.map((item) {
                          final id = int.parse(item['id'].toString());
                          final nombre = (item['nombre'] ?? item['descripcion'] ?? 'Alergia $id').toString();
                          final selected = _seleccion.contains(id);
                          return ChoiceChip(
                            label: Text(
                              nombre,
                              style: TextStyle(
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                if (selected) {
                                  _seleccion.remove(id);
                                } else {
                                  _seleccion.add(id);
                                }
                              });
                            },
                            avatar: selected
                                ? const Icon(Icons.check, size: 18, color: kPrimary)
                                : null,
                            selectedColor: kPrimary.withOpacity(.14),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: selected ? kText : Colors.black87,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: selected ? kPrimary : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom bar fija
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                        color: Colors.black.withOpacity(.07),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            sel == 0
                                ? 'Nada seleccionado'
                                : (sel == 1 ? '1 alergia seleccionada' : '$sel alergias seleccionadas'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _guardar,
                            icon: _saving
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(Icons.save_outlined),
                            label: Text(_saving ? 'Guardando…' : 'Guardar'),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
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
}

/* ====== Widgets pequeñitos reutilizables ====== */

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        prefixIcon: const Icon(Icons.search, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AlergiasPageState.kPrimary),
        ),
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _AlergiasPageState.kPrimary.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _AlergiasPageState.kPrimary),
      ),
      child: Text(text,
          style: const TextStyle(
              color: _AlergiasPageState.kPrimary, fontWeight: FontWeight.w700)),
    );
  }
}

Widget _ghostBtn(IconData icon, String label, {required VoidCallback onTap}) {
  return OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 18, color: _AlergiasPageState.kPrimary),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: _AlergiasPageState.kPrimary,
      side: BorderSide(color: _AlergiasPageState.kPrimary.withOpacity(.6)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
