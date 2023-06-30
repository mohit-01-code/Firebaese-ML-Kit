import 'package:flutter/material.dart';
import 'package:text_recognition_app/ml_screen.dart';

class  HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  List<String> itemsList = [
    'Text Scanner',
    'Barcode Scanner',
    'Label Scanner',
    'Face Detection'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Kit Demo'),
      ),
      body: ListView.builder(
          itemCount: itemsList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(itemsList[index]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MlScreen(),
                      settings: RouteSettings(arguments: itemsList[index]),
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
