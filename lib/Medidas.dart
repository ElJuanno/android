import 'package:flutter/material.dart';

class NutritionalMeasuresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Medidas Antropométricas', style: TextStyle(color: Colors.green)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.green),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descripción general del estado nutricional',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 10),
            Image.asset('assets/nutrition_description.jpg', height: 200, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(
              'Esta pantalla proporciona una descripción general completa de su estado nutricional, incluidas métricas clave.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Estado nutricional',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                buildCard('Peso corporal', 'assets/weight.jpg'),
                buildCard('Altura', 'assets/height.jpg'),
                buildCard('IMC', 'assets/bmi.jpg'),
                buildCard('Circunferencia de la cintura', 'assets/waist.jpg'),
                buildCard('Circunferencia de la cadera', 'assets/hip.jpg'),
                buildCard('Longitud de las extremidades', 'assets/limbs.jpg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(String title, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(imagePath, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            child: Text('Ver detalles', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}