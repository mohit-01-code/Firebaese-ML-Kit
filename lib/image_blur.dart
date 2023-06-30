import 'dart:ui';
import 'package:flutter/material.dart';

class ImageBlur extends StatelessWidget {
  final ImageProvider imageProvider;
  final Rect blurRect;
  final double blurSigma;

  const ImageBlur({
    super.key,
    required this.imageProvider,
    required this.blurRect,
    this.blurSigma = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Image(image: imageProvider),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: FractionalTranslation(
                  translation: Offset(
                    -blurRect.left / blurRect.width,
                    -blurRect.top / blurRect.height,
                  ),
                  child: ClipRect(
                    child: Container(
                      width: blurRect.width,
                      height: blurRect.height,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
