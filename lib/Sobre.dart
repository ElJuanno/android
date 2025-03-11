import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'DIETALI',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.green),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset('assets/sobre.png', height: 200, fit: BoxFit.cover),
            ),
            SizedBox(height: 15),
            Text(
              'Acerca de DIETALI',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'DIETALI es una aplicación diseñada para incentivar a personas con enfermedades crónicas como la diabetes a '
                  'tener una alimentación saludable mediante planes alimenticios basados en alimentos registrados.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            buildInfoCard(Icons.phone, 'Teléfono', '7225616267', isPhone: true),
            buildInfoCard(Icons.email, 'Correo', 'anamari.goce@gmail.com'),
            buildInfoCard(Icons.location_on, 'Dirección', 'Valle de Bravo, Estado de México'),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard(IconData icon, String label, String value, {bool isPhone = false}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        subtitle: GestureDetector(
          onTap: () async {
            if (isPhone) {
              final Uri phoneUri = Uri(scheme: 'tel', path: value);
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri);
              } else {
                throw 'No se pudo abrir la app de llamadas';
              }
            }
          },
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
  }
}
