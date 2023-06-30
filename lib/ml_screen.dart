import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:text_recognition_app/face_detection.dart';

class MlScreen extends StatefulWidget {
  const MlScreen({super.key});

  @override
  State<MlScreen> createState() => _MlScreenState();
}

class _MlScreenState extends State<MlScreen> {
  File? _pickedImageFile;
  String scannedText = "";
  String selectedItem = '';

  @override
  Widget build(BuildContext context) {
    selectedItem = ModalRoute.of(context)!.settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Extractor"),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_pickedImageFile == null)
              Image.asset('assets/images/img.png')
            else
              Image.file(_pickedImageFile!),
            const SizedBox(
              height: 10
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
              height: 10
            ),
            Text(scannedText),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            detectMLFeature(selectedItem);
          },
          tooltip: "Extract Text",
          child: const Icon(Icons.done)),
    );
  }

  void detectMLFeature(String selectedFeature) {
    switch (selectedFeature) {
      case 'Text Scanner':
        readTextFromImage();
        break;
      case 'Barcode Scanner':
        decodeBarCode();
        break;
      case 'Label Scanner':
        labelsRead();
        break;
      case 'Face Detection':
        detectFace();
        break;
    }
  }

  void _pickImage(ImageSource source) async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: source,
    );
    if (pickedImage == null) return;
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
  }

  void readTextFromImage() async {
    final InputImage inputImage =
        InputImage.fromFilePath(_pickedImageFile!.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = "$scannedText${line.text}\n";
      }
    }
    setState(() {});
  }

  void labelsRead() async {
    final inputImage = InputImage.fromFilePath(_pickedImageFile!.path);
    ImageLabeler imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    StringBuffer sb = StringBuffer();
    for (ImageLabel imgLabel in labels) {
      String lblText = imgLabel.label;
      double confidence = imgLabel.confidence;
      sb.write(lblText);
      sb.write(" : ");
      sb.write((confidence * 100).toStringAsFixed(2));
      sb.write("%");
    }
    imageLabeler.close();
    setState(() {
      scannedText = sb.toString();
    });
  }

  void decodeBarCode() {}

  void detectFace() async{
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>const FaceBlurScreen()));
  }
}
