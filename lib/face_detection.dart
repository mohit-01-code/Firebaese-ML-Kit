import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceBlurScreen extends StatefulWidget {
  const FaceBlurScreen({super.key});

  @override
  State<FaceBlurScreen> createState() => _FaceBlurScreenState();
}

class _FaceBlurScreenState extends State<FaceBlurScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector();

  ui.Image? _image;
  List<Face> _faces = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Blur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_image == null)
              const Text('No image selected')
            else
              SizedBox(
                height: 300,
                child: FittedBox(
                  child: SizedBox(
                    width: _image!.width.toDouble(),
                    height: _image!.height.toDouble(),
                    child: CustomPaint(
                      painter: FacePainter(_image!, _faces),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _blurFaces,
              child: const Text('Blur Faces'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    final pickedImage = await _imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      final imageFile = File(pickedImage.path);
      final imageBytes = await imageFile.readAsBytes();

      final image = await decodeImageFromList(imageBytes);
      setState(() {
        _image = image;
      });

      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      setState(() {
        _faces = faces;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _blurFaces() async {
    setState(() {
      _isLoading = true;
    });
    _showBlurredImage(_image);

    setState(() {
      _isLoading = false;
    });
  }

  void _showBlurredImage(ui.Image? blurredImage) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: blurredImage != null
                ? FittedBox(
                    child: SizedBox(
                      width: blurredImage.width.toDouble(),
                      height: blurredImage.height.toDouble(),
                      child: CustomPaint(
                        painter: BlurPainter(blurredImage, _faces),
                      ),
                    ),
                  )
                : const Center(child: Text('Error processing image')),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }
}

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;

  FacePainter(this.image, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.red;

    canvas.drawImage(image, Offset.zero, Paint());

    for (var face in faces) {
      canvas.drawRect(face.boundingBox, paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.faces != faces;
  }
}

class BlurPainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final blurFilter = ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0);
  BlurPainter(this.image, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint()..style = PaintingStyle.stroke);

    for (Face face in faces) {
      canvas.saveLayer(face.boundingBox, Paint()..imageFilter = blurFilter);
      canvas.drawImageRect(
        image,
        face.boundingBox,
        face.boundingBox,
        Paint(),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.faces != faces;
  }

}
