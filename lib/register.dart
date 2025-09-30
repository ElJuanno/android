// lib/register.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pru/General.dart'; // HomeMobilePage

const String kAuthBase = 'http://137.184.183.35/api';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey  = GlobalKey<FormState>();
  final _nombre   = TextEditingController();
  final _apellidoP= TextEditingController();
  final _apellidoM= TextEditingController();
  final _correo   = TextEditingController();
  final _curp     = TextEditingController();
  final _pass     = TextEditingController();
  final _pass2    = TextEditingController();

  String _sexo = 'H';
  bool _loading = false;
  bool _ob1 = true, _ob2 = true;

  // Misma paleta que el login
  final Color _primary  = const Color(0xFF00A86B);
  final Color _textDark = const Color(0xFF103B2D);

  @override
  void dispose() {
    _nombre.dispose();
    _apellidoP.dispose();
    _apellidoM.dispose();
    _correo.dispose();
    _curp.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pass.text.trim() != _pass2.text.trim()) {
      _showError('Las contraseñas no coinciden');
      return;
    }

    setState(() => _loading = true);
    try {
      final body = {
        'nombre': _nombre.text.trim(),
        'apellido_p': _apellidoP.text.trim(),
        'apellido_m': _apellidoM.text.trim(),
        'sexo': _sexo, // 'H' o 'M'
        'curp': _curp.text.trim().isEmpty ? null : _curp.text.trim(),
        'correo': _correo.text.trim(),
        // nombres compatibles con tu backend
        'contrasena': _pass.text.trim(),
        'contrasena_confirmation': _pass2.text.trim(),
        'password': _pass.text.trim(),
        'password_confirmation': _pass2.text.trim(),
      };

      final res = await http.post(
        Uri.parse('$kAuthBase/register'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final j = jsonDecode(res.body);
        final token = (j['access_token'] ?? j['token'])?.toString();
        if (token != null && token.isNotEmpty) {
          final p = await SharedPreferences.getInstance();
          await p.setString('token', token);
        }
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeMobilePage()),
              (_) => false,
        );
      } else {
        String msg = 'Error ${res.statusCode}';
        try {
          final j = jsonDecode(res.body);
          msg = j['message']?.toString() ?? msg;
        } catch (_) {}
        _showError(msg);
      }
    } catch (e) {
      _showError('Error de red: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('No pudimos crear la cuenta'),
        content: Text(msg.isEmpty ? 'Ocurrió un error inesperado.' : msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: _textDark,
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  // Logo (igual que en login)
                  Image.asset('assets/logo.png', height: 110),
                  const SizedBox(height: 12),

                  Text(
                    'Únete a Dietali',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Crea tu cuenta para comenzar',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Tarjeta del formulario (misma estética)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Nombre + Sexo
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Nombre'),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _nombre,
                                      decoration: _inputDeco(
                                        hint: 'Tu nombre',
                                        icon: Icons.person_outline,
                                      ),
                                      validator: (v) => (v == null || v.trim().isEmpty)
                                          ? 'Requerido'
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Sexo'),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _sexo,
                                      decoration: _inputDeco(
                                        hint: 'Selecciona',
                                        icon: Icons.wc_outlined,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'H', child: Text('Hombre'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'M', child: Text('Mujer'),
                                        ),
                                      ],
                                      onChanged: (v) => setState(() => _sexo = v ?? 'H'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Apellidos
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Apellido paterno'),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _apellidoP,
                                      decoration: _inputDeco(
                                        hint: 'Opcional',
                                        icon: Icons.badge_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Apellido materno'),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _apellidoM,
                                      decoration: _inputDeco(
                                        hint: 'Opcional',
                                        icon: Icons.badge_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Correo
                          Align(alignment: Alignment.centerLeft, child: _label('Correo')),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _correo,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDeco(
                              hint: 'ejemplo@correo.com',
                              icon: Icons.email_outlined,
                            ),
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty) return 'Requerido';
                              final ok = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(value);
                              if (!ok) return 'Correo no válido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // CURP
                          Align(alignment: Alignment.centerLeft, child: _label('CURP (opcional)')),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _curp,
                            decoration: _inputDeco(
                              hint: 'Ingresa tu CURP',
                              icon: Icons.credit_card_outlined,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Contraseñas
                          Align(alignment: Alignment.centerLeft, child: _label('Contraseña')),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pass,
                            obscureText: _ob1,
                            decoration: _inputDeco(
                              hint: 'Mínimo 6 caracteres',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                onPressed: () => setState(() => _ob1 = !_ob1),
                                icon: Icon(_ob1
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                tooltip: _ob1 ? 'Mostrar' : 'Ocultar',
                              ),
                            ),
                            validator: (v) =>
                            (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                          ),
                          const SizedBox(height: 18),

                          Align(alignment: Alignment.centerLeft, child: _label('Confirmar contraseña')),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pass2,
                            obscureText: _ob2,
                            decoration: _inputDeco(
                              hint: 'Repite tu contraseña',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                onPressed: () => setState(() => _ob2 = !_ob2),
                                icon: Icon(_ob2
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                tooltip: _ob2 ? 'Mostrar' : 'Ocultar',
                              ),
                            ),
                            validator: (v) =>
                            (v == null || v.isEmpty) ? 'Confirma tu contraseña' : null,
                          ),
                          const SizedBox(height: 22),

                          // Botón crear cuenta
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _doRegister,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: _primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.6,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                                  : const Text(
                                'Crear cuenta',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => Navigator.pushReplacementNamed(context, '/login'),
                            child: const Text(
                              '¿Ya tienes cuenta? Inicia sesión',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Text _label(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: _textDark,
      ),
    );
  }

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: _primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF6FAF8),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
    );
  }
}
