import 'package:flutter/material.dart';

class MedicosPage extends StatelessWidget {
  const MedicosPage({super.key});

  static const kPrimary = Color(0xFF00A86B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Médicos'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPrimary.withOpacity(.25)),
          ),
          child: const Text(
            'Próximamente 👨‍⚕️👩‍⚕️',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
