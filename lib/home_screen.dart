import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _pickedImageFile;
  String scannedText = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Extractor"),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_pickedImageFile == null)
            Image.asset('assets/images/img.png')
          else
            Image.file(_pickedImageFile!),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    _pickImage(ImageSource.gallery);
                  },
                  tooltip: "Gallery",
                  icon: const Icon(Icons.photo)),
              const SizedBox(
                width: 10,
              ),
              IconButton(
                  onPressed: () {
                    _pickImage(ImageSource.camera);
                  },
                  tooltip: "Camera",
                  icon: const Icon(Icons.camera_alt)),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(scannedText),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _recognizeText,
          tooltip: "Extract Text",
          child: const Icon(Icons.done)),
    );
  }

  void _pickImage(ImageSource source) async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: source,
      imageQuality: 100,
      maxWidth: 150,
    );
    if (pickedImage == null) return;
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
  }

  void _recognizeText() async {
    final InputImage inputImage =
        InputImage.fromFilePath(_pickedImageFile!.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
      }
    }
    setState(() {});
  }
}
