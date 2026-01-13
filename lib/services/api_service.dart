// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Cliente mínimo para manejar cookies (Sanctum SPA) cuando el backend
/// autentica por sesión en lugar de tokens Bearer.
class CookieClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  String? _cookie;    // "laravel_session=...; XSRF-TOKEN=..."
  String? _xsrfToken; // Valor decodificado de XSRF-TOKEN

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (_cookie != null && _cookie!.isNotEmpty) {
      request.headers['Cookie'] = _cookie!;
    }
    if (_xsrfToken != null && _xsrfToken!.isNotEmpty) {
      request.headers['X-XSRF-TOKEN'] = _xsrfToken!;
    }
    request.headers['X-Requested-With'] = 'XMLHttpRequest';
    return _inner.send(request);
  }

  void captureSetCookie(http.Response res) {
    final setCookie = res.headers['set-cookie'];
    if (setCookie == null) return;

    final cookies = <String>[];
    for (final part in setCookie.split(',')) {
      final cookie = part.split(';').first.trim();
      if (cookie.isEmpty) continue;
      cookies.add(cookie);
      if (cookie.startsWith('XSRF-TOKEN=')) {
        _xsrfToken = Uri.decodeComponent(cookie.substring('XSRF-TOKEN='.length));
      }
    }
    _cookie = cookies.join('; ');
  }

  String? get cookie => _cookie;
  String? get xsrf => _xsrfToken;

  void clear() {
    _cookie = null;
    _xsrfToken = null;
  }
}

class ApiService {
  ApiService._();
  static final ApiService I = ApiService._();

  // ===================== BASE =====================
  static String _apiBase = 'http://137.184.183.35/api'; // ajusta si cambia
  static void setApiBase(String base) {
    _apiBase = base.replaceAll(RegExp(r'/+$'), '');
  }

  // ===================== HELPERS =====================
  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<String?> getToken() async {
    final p = await _prefs();
    return p.getString('token');
  }

  Future<void> _saveToken(String? token) async {
    final p = await _prefs();
    if (token == null || token.isEmpty) {
      await p.remove('token');
    } else {
      await p.setString('token', token);
    }
  }

  Future<bool> isLoggedIn() async => (await getToken())?.isNotEmpty == true;

  Map<String, String> _jsonHeaders({String? token}) {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  Exception _backendError(http.Response res) {
    try {
      final j = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      final msg = (j is Map && j['message'] is String)
          ? j['message'] as String
          : 'Error';
      final errs = (j is Map && j['errors'] != null) ? j['errors'].toString() : null;
      if (res.statusCode == 401) {
        return Exception('Sesión expirada o inválida. Vuelve a iniciar sesión. [$msg]');
      }
      return Exception('$msg [${res.statusCode}]${errs != null ? ' → $errs' : ''}');
    } catch (_) {
      return Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  Future<http.Response> _post(
      Uri uri, {
        Map<String, dynamic>? body,
        Duration timeout = const Duration(seconds: 60),
      }) async {
    final token = await getToken();
    final res = await http
        .post(uri, headers: _jsonHeaders(token: token), body: jsonEncode(body ?? {}))
        .timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) throw _backendError(res);
    return res;
  }

  Future<http.Response> _get(
      Uri uri, {
        Duration timeout = const Duration(seconds: 60),
      }) async {
    final token = await getToken();
    final res = await http.get(uri, headers: _jsonHeaders(token: token)).timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) throw _backendError(res);
    return res;
  }

  Future<http.Response> _delete(
      Uri uri, {
        Duration timeout = const Duration(seconds: 60),
      }) async {
    final token = await getToken();
    final res = await http.delete(uri, headers: _jsonHeaders(token: token)).timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) throw _backendError(res);
    return res;
  }

  // =======================  AUTH (Bearer preferido)  =========================

  /// Extrae token de múltiples formas: token, access_token, data.token, user.token, etc.
  String? _extractToken(dynamic data) {
    if (data == null) return null;
    if (data is String) return data.trim().isEmpty ? null : data.trim();
    if (data is Map) {
      final candidates = <String?>[
        data['access_token'] as String?,
        data['token'] as String?,
        (data['data'] is Map) ? (data['data']['token'] as String?) : null,
        (data['user'] is Map) ? (data['user']['token'] as String?) : null,
      ];
      for (final t in candidates) {
        if (t != null && t.trim().isNotEmpty) return t.trim();
      }
    }
    return null;
  }

  Future<void> register({
    required String nombre,
    required String correo,
    required String contrasena,
    required String contrasenaConfirmation,
    String? apellidoP,
    String? apellidoM,
    String sexo = 'H',
    String? curp,
  }) async {
    // Intento 1: payload "es"
    final payloadEs = {
      'nombre': nombre.trim(),
      'apellido_p': (apellidoP ?? '').trim(),
      'apellido_m': (apellidoM ?? '').trim(),
      'sexo': sexo.trim(),
      'curp': curp,
      'correo': correo.trim(),
      'contrasena': contrasena.trim(),
      'contrasena_confirmation': contrasenaConfirmation.trim(),
      // compat
      'password': contrasena.trim(),
      'password_confirmation': contrasenaConfirmation.trim(),
    };

    http.Response res = await http
        .post(
      Uri.parse('$_apiBase/register'),
      headers: _jsonHeaders(),
      body: jsonEncode(payloadEs),
    )
        .timeout(const Duration(seconds: 60));

    // Si el backend no acepta estos nombres de campos, probamos variante "en"
    if (res.statusCode >= 400 && res.statusCode < 500) {
      final payloadEn = {
        'name': nombre.trim(),
        'last_name_p': (apellidoP ?? '').trim(),
        'last_name_m': (apellidoM ?? '').trim(),
        'gender': sexo.trim(),
        'curp': curp,
        'email': correo.trim(),
        'password': contrasena.trim(),
        'password_confirmation': contrasenaConfirmation.trim(),
      };
      final res2 = await http
          .post(
        Uri.parse('$_apiBase/register'),
        headers: _jsonHeaders(),
        body: jsonEncode(payloadEn),
      )
          .timeout(const Duration(seconds: 60));
      if (res2.statusCode == 200 || res2.statusCode == 201) {
        final data = jsonDecode(res2.body);
        final token = _extractToken(data);
        await _saveToken(token);
        return;
      }
      throw _backendError(res2);
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final token = _extractToken(data);
      await _saveToken(token);
      return;
    }
    throw _backendError(res);
  }

  Future<void> login({
    required String correo,
    required String contrasena,
  }) async {
    // Intento 1: llaves "es"
    http.Response res = await http
        .post(
      Uri.parse('$_apiBase/login'),
      headers: _jsonHeaders(),
      body: jsonEncode({'correo': correo.trim(), 'contrasena': contrasena.trim()}),
    )
        .timeout(const Duration(seconds: 60));

    // Si falla por cliente (422/400/401), intentamos variante "en"
    if (res.statusCode >= 400 && res.statusCode < 500) {
      final res2 = await http
          .post(
        Uri.parse('$_apiBase/login'),
        headers: _jsonHeaders(),
        body: jsonEncode({'email': correo.trim(), 'password': contrasena.trim()}),
      )
          .timeout(const Duration(seconds: 60));
      if (res2.statusCode == 200 || res2.statusCode == 201) {
        final data = jsonDecode(res2.body);
        final token = _extractToken(data);
        if (token == null) throw Exception('Login ok pero sin token en la respuesta.');
        await _saveToken(token);
        return;
      }
      throw _backendError(res2);
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final token = _extractToken(data);
      if (token == null) throw Exception('Login ok pero sin token en la respuesta.');
      await _saveToken(token);
      return;
    }
    throw _backendError(res);
  }

  Future<void> logout() async {
    try {
      final res = await _post(Uri.parse('$_apiBase/logout'));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        // ignoramos, pero limpiamos token local
      }
    } catch (_) {
      // ignoramos
    } finally {
      await _saveToken(null);
      _cookieClient.clear();
    }
  }

  // =======================  AUTH (Cookies opcional)  =========================
  final CookieClient _cookieClient = CookieClient();

  /// Usa este login si tu backend autentica por **cookies de sesión** (Sanctum SPA).
  /// OJO: las rutas suelen ser /sanctum/csrf-cookie y /login fuera de /api.
  Future<void> loginWithCookies({
    required String correo,
    required String contrasena,
    String csrfPath = '/sanctum/csrf-cookie',
    String loginPath = '/login',
  }) async {
    // Derivamos base de host sin /api para pegarle a rutas de sesión
    final hostBase = _apiBase.endsWith('/api')
        ? _apiBase.substring(0, _apiBase.length - 4)
        : _apiBase;

    // 1) CSRF
    final csrf = await _cookieClient._inner.get(
      Uri.parse('$hostBase$csrfPath'),
      headers: {'Accept': 'application/json'},
    );
    _cookieClient.captureSetCookie(csrf);

    // 2) LOGIN
    final res = await _cookieClient._inner.post(
      Uri.parse('$hostBase$loginPath'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        if (_cookieClient.cookie != null) 'Cookie': _cookieClient.cookie!,
        if (_cookieClient.xsrf != null) 'X-XSRF-TOKEN': _cookieClient.xsrf!,
      },
      body: jsonEncode({
        'email': correo.trim(),       // o 'correo', según tu backend
        'password': contrasena.trim() // o 'contrasena'
      }),
    );
    _cookieClient.captureSetCookie(res);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw _backendError(res);
    }
  }

  /// Ejemplo de GET autenticado por cookies (consulta usuario)
  Future<Map<String, dynamic>> whoAmIByCookies() async {
    final r = await _cookieClient._inner.get(
      Uri.parse('$_apiBase/user'),
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        if (_cookieClient.cookie != null) 'Cookie': _cookieClient.cookie!,
        if (_cookieClient.xsrf != null) 'X-XSRF-TOKEN': _cookieClient.xsrf!,
      },
    );
    if (r.statusCode < 200 || r.statusCode >= 300) throw _backendError(r);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  // =====================  DEBUG / DIAGNÓSTICO  ======================
  Future<void> debugPrintToken() async {
    final t = await getToken();
    // ignore: avoid_print
    print('TOKEN => ${t ?? "(null)"}');
  }

  /// Verifica autenticación por Bearer → **usa /me directamente**.
  Future<Map<String, dynamic>> whoAmI() async {
    final r = await _get(Uri.parse('$_apiBase/me'));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  /// Ping público simple para verificar conectividad del API.
  Future<bool> ping() async {
    try {
      final r = await http.get(Uri.parse('$_apiBase/ping'),
          headers: {'Accept': 'application/json'});
      return r.statusCode >= 200 && r.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // ====================  PLANES / RECETAS ====================
  /// POST /api/plan/recetas  (modo=agrupadas). Normaliza y corrige nutrimentos.
  Future<Map<String, dynamic>> planRecetas({
    int? seed,
    String modo = 'agrupadas',
  }) async {
    final res = await _post(
      Uri.parse('$_apiBase/plan/recetas'),
      body: {'modo': modo, if (seed != null) 'seed': seed},
    );
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final agrupadas = j['agrupadas'] ?? j['recetas'] ?? {};

    // Aplicar fix de nutrición (x100 cal si <10, x10 carbs si <1)
    if (agrupadas is Map) {
      for (final entry in agrupadas.entries) {
        final list = entry.value;
        if (list is List) {
          for (final r in list) {
            if (r is Map) _fixNutrition(r);
          }
        }
      }
    } else if (agrupadas is List) {
      for (final r in agrupadas) {
        if (r is Map) _fixNutrition(r);
      }
    }

    return {...j, 'agrupadas': agrupadas};
  }

  // ====================  GLUCOSA ====================
  Future<Map<String, dynamic>> glucosaIndex({
    String? desde,
    String? hasta,
    int limit = 100,
  }) async {
    final qp = <String, String>{'limit': '$limit'};
    if (desde != null && desde.isNotEmpty) qp['desde'] = desde;
    if (hasta != null && hasta.isNotEmpty) qp['hasta'] = hasta;
    final uri = Uri.parse('$_apiBase/glucosa').replace(queryParameters: qp);
    final res = await _get(uri);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> glucosaCreate({
    required double glucosa,
    required int edad,
    String? presion,
    double? frecuencia,
    String? condicion,
  }) async {
    final body = {
      'glucosa': glucosa,
      'edad': edad,
      if (presion != null && presion.isNotEmpty) 'presion': presion,
      if (frecuencia != null) 'frecuencia': frecuencia,
      if (condicion != null && condicion.isNotEmpty) 'condicion': condicion,
    };
    final res = await _post(Uri.parse('$_apiBase/glucosa'), body: body);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> glucosaDelete(int id) async {
    final res = await _delete(Uri.parse('$_apiBase/glucosa/$id'));
    if (res.statusCode == 204) return;
  }

  // ====================  ALERGIAS ====================
  Future<List<Map<String, dynamic>>> alergiasCatalogo() async {
    final res = await _get(Uri.parse('$_apiBase/alergias'));
    final j = jsonDecode(res.body);

    final out = <Map<String, dynamic>>[];

    if (j is List) {
      for (final e in j) {
        if (e is Map) {
          final m = e.cast<String, dynamic>();
          final id = int.tryParse(m['id']?.toString() ?? '');
          final nombre = (m['nombre'] ??
              m['descripcion'] ??
              m['name'] ??
              m['desc'] ??
              '')
              .toString()
              .trim();
          if (id != null) {
            out.add({'id': id, 'nombre': nombre.isEmpty ? 'Alergia $id' : nombre});
          }
        }
      }
      return out;
    }

    if (j is Map && j['items'] is List) {
      for (final e in j['items'] as List) {
        if (e is Map) {
          final m = e.cast<String, dynamic>();
          final id = int.tryParse(m['id']?.toString() ?? '');
          final nombre = (m['nombre'] ?? m['descripcion'] ?? '').toString().trim();
          if (id != null) {
            out.add({'id': id, 'nombre': nombre.isEmpty ? 'Alergia $id' : nombre});
          }
        }
      }
      return out;
    }

    return out;
  }

  Future<List<int>> alergiasMis() async {
    final res = await _get(Uri.parse('$_apiBase/alergias/mis'));
    final j = jsonDecode(res.body);
    if (j is List) return j.map((e) => int.parse(e.toString())).toList();
    if (j is Map && j['ids'] is List) {
      return (j['ids'] as List).map((e) => int.parse(e.toString())).toList();
    }
    return const [];
  }

  Future<void> alergiasGuardar(List<int> ids) async {
    final res = await _post(Uri.parse('$_apiBase/alergias/mis'), body: {'ids': ids});
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw _backendError(res);
  }

  // ====================  COMIDAS / SEGUIMIENTOS ====================
  /// GET /api/seguimiento → { items:[], totals:{...}, start,end }
  Future<Map<String, dynamic>> comidasIndex({
    String? desde,
    String? hasta,
    int limit = 100,
  }) async {
    final qp = <String, String>{'limit': '$limit'};
    if (desde != null && desde.isNotEmpty) qp['desde'] = desde;
    if (hasta != null && hasta.isNotEmpty) qp['hasta'] = hasta;

    final uri = Uri.parse('$_apiBase/seguimiento').replace(queryParameters: qp);
    final res = await _get(uri);

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    // Ajuste nutricional en items
    final items = data['items'];
    if (items is List) {
      for (final e in items) {
        if (e is Map) _fixNutrition(e);
      }
    }
    // Totales (si el backend no los manda, calculamos básicos)
    if (data['totals'] == null && items is List) {
      double cals = 0, sugar = 0, carbs = 0;
      for (final e in items) {
        if (e is Map) {
          cals += double.tryParse('${e['calorias'] ?? 0}') ?? 0;
          sugar += double.tryParse('${e['azucar'] ?? 0}') ?? 0;
          carbs += double.tryParse('${e['carbohidratos'] ?? 0}') ?? 0;
        }
      }
      data['totals'] = {
        'calorias': double.parse(cals.toStringAsFixed(1)),
        'azucar': double.parse(sugar.toStringAsFixed(1)),
        'carbohidratos': double.parse(carbs.toStringAsFixed(1)),
      };
    }
    return data;
  }

  /// POST /api/seguimiento
  Future<Map<String, dynamic>> comidasCreate({
    required String nombre,
    required num calorias,
    required num azucar,
    required num carbohidratos,
    String? momento, // se envía como 'tiempo'
    int? recetaId, // opcional (puede ir en metadata)
    DateTime? fecha, // opcional
  }) async {
    String _yyyyMmDd(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    String _hhMmSs(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';

    final body = <String, dynamic>{
      'nombre': nombre,
      'calorias': calorias,
      'azucar': azucar,
      'carbohidratos': carbohidratos,
      if (momento != null && momento.isNotEmpty) 'tiempo': momento,
      // si no mandas fecha/hora, backend pone now()
      if (fecha != null) 'fecha': _yyyyMmDd(fecha),
      if (fecha != null) 'hora': _hhMmSs(fecha),
      'source': 'mobile',
      if (recetaId != null && recetaId > 0) 'metadata': {'receta_id': recetaId},
    };

    final res = await _post(Uri.parse('$_apiBase/seguimiento'), body: body);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    _fixNutrition(data);
    return data;
  }

  /// DELETE /api/seguimiento/{id}
  Future<void> comidasDelete(int id) async {
    final res = await _delete(Uri.parse('$_apiBase/seguimiento/$id'));
    if (res.statusCode == 204) return;
  }

  // ====================  SALUD ====================
  /// GET /api/salud/resumen → { glucosa, presion, frecuencia, imc, fecha }
  Future<Map<String, dynamic>> saludResumen() async {
    final res = await _get(Uri.parse('$_apiBase/salud/resumen'));
    final j = jsonDecode(res.body);
    if (j is Map<String, dynamic>) return j;
    return {
      'glucosa': null,
      'presion': '',
      'frecuencia': null,
      'imc': null,
      'fecha': null,
    };
  }

  /// GET /api/salud/series?days=30
  /// → { labels:[], glucosa:[], fc:[], sys:[], dia:[] }
  Future<Map<String, dynamic>> saludSeries({int days = 30}) async {
    final uri = Uri.parse('$_apiBase/salud/series').replace(queryParameters: {'days': '$days'});
    final res = await _get(uri);
    final j = jsonDecode(res.body);
    if (j is Map<String, dynamic>) {
      return {
        'labels': j['labels'] ?? j['fechas'] ?? const [],
        'glucosa': j['glucosa'] ?? j['glucose'] ?? const [],
        'fc': j['fc'] ?? j['frecuencia'] ?? const [],
        'sys': j['sys'] ?? j['sistolica'] ?? const [],
        'dia': j['dia'] ?? j['diastolica'] ?? const [],
      };
    }
    return {
      'labels': const [],
      'glucosa': const [],
      'fc': const [],
      'sys': const [],
      'dia': const [],
    };
  }

  // ====================  UTILS (ajuste de nutrición) ====================
  void _fixNutrition(Map<dynamic, dynamic> item) {
    // calorías < 10 → x100
    if (item['calorias'] != null) {
      final c = double.tryParse(item['calorias'].toString()) ?? 0;
      if (c < 10) item['calorias'] = double.parse((c * 100).toStringAsFixed(1));
    }
    // carbohidratos < 1 → x10
    if (item['carbohidratos'] != null) {
      final carbs = double.tryParse(item['carbohidratos'].toString()) ?? 0;
      if (carbs < 1) {
        item['carbohidratos'] = double.parse((carbs * 10).toStringAsFixed(1));
      }
    }
  }
}
