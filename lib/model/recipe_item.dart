// lib/model/recipe_item.dart

class RecipeItem {
  final int id;                 // <--- NUEVO
  final String nombre;
  final String ingredientes;
  final String categoria;
  final String color;
  final double calorias;
  final double carbohidratos;
  final double azucar;

  RecipeItem({
    required this.id,           // <--- NUEVO
    required this.nombre,
    required this.ingredientes,
    required this.categoria,
    required this.color,
    required this.calorias,
    required this.carbohidratos,
    required this.azucar,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> j) {
    double _num(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse('$v') ?? 0;
    }

    int _int(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return RecipeItem(
      id: _int(j['id']), // <--- NUEVO (si no viene, queda 0)
      nombre: (j['nombre'] ?? j['title'] ?? '').toString(),
      ingredientes: (j['ingredientes'] ?? j['ingredients'] ?? '').toString(),
      categoria: (j['categoria'] ?? j['meal'] ?? '').toString(),
      color: (j['color'] ?? 'verde').toString(),
      calorias: _num(j['calorias'] ?? j['cal'] ?? j['kcal']),
      carbohidratos: _num(j['carbohidratos'] ?? j['carbs']),
      azucar: _num(j['azucar'] ?? j['azucar_g']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'ingredientes': ingredientes,
    'categoria': categoria,
    'color': color,
    'calorias': calorias,
    'carbohidratos': carbohidratos,
    'azucar': azucar,
  };
}

class GlucosaItem {
  final int id;
  final double glucosa;
  final String? presion;
  final double? frecuencia;
  final String? condicion;
  final int? edad;
  final DateTime createdAt;

  GlucosaItem({
    required this.id,
    required this.glucosa,
    this.presion,
    this.frecuencia,
    this.condicion,
    this.edad,
    required this.createdAt,
  });

  factory GlucosaItem.fromJson(Map<String, dynamic> j) {
    DateTime parseDate(String s) {
      final d = DateTime.tryParse(s);
      return d ?? DateTime.now();
    }

    return GlucosaItem(
      id: (j['id'] ?? 0) as int,
      glucosa: (j['glucosa'] as num?)?.toDouble() ?? 0.0,
      presion: j['presion']?.toString(),
      frecuencia: (j['frecuencia'] as num?)?.toDouble(),
      condicion: j['condicion']?.toString(),
      edad: (j['edad'] as num?)?.toInt(),
      createdAt: j['created_at'] is String
          ? parseDate(j['created_at'] as String)
          : DateTime.now(),
    );
  }
}
