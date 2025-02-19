import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      home: NombreCRUD(),
    );
  }
}

class ThemeConfig {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.teal,
    hintColor: Colors.amber,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.teal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: Colors.teal[700],
    hintColor: Colors.amber[700],
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.teal[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

class NombreCRUD extends StatefulWidget {
  @override
  _NombreCRUDState createState() => _NombreCRUDState();
}

class _NombreCRUDState extends State<NombreCRUD> {
  final TextEditingController _nombreController = TextEditingController();
  List<String> nombres = [];
  int? _indexEdicion;

  Future<bool> _mostrarDialogoConfirmacion(String titulo, String contenido) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(contenido),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  void guardarNombre() async {
    String nombre = _nombreController.text.trim();
    if (nombre.isNotEmpty) {
      bool confirmado = await _mostrarDialogoConfirmacion(
        'Confirmar ${_indexEdicion == null ? 'agregar' : 'editar'}',
        '¿Estás seguro de que deseas ${_indexEdicion == null ? 'agregar' : 'editar'} el nombre "$nombre"?',
      );
      if (confirmado) {
        setState(() {
          if (_indexEdicion == null) {
            nombres.add(nombre);
          } else {
            nombres[_indexEdicion!] = nombre;
            _indexEdicion = null;
          }
        });
        _nombreController.clear();
      }
    }
  }

  void editarNombre(int index) {
    _nombreController.text = nombres[index];
    setState(() {
      _indexEdicion = index;
    });
  }

  void eliminarNombre(int index) async {
    bool confirmado = await _mostrarDialogoConfirmacion(
      'Confirmar eliminación',
      '¿Estás seguro de que deseas eliminar el nombre "${nombres[index]}"?',
    );
    if (confirmado) {
      setState(() {
        nombres.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CRUD de Nombres"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.teal, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.teal, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: guardarNombre,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(_indexEdicion == null ? 'Agregar Nombre' : 'Guardar Cambios'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: nombres.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        nombres[index],
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: () => editarNombre(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => eliminarNombre(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}