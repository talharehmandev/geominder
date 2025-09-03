import 'dart:io';
import 'package:flutter/material.dart';

void showFullScreenImage(
    BuildContext context,
    dynamic imageSource, {
      ImageType type = ImageType.network,
    }) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: _buildImage(imageSource, type),
            ),
          ),
        ),
      ),
    ),
  );
}

enum ImageType { network, asset, file }

Widget _buildImage(dynamic source, ImageType type) {
  switch (type) {
    case ImageType.asset:
      return Image.asset(source, fit: BoxFit.contain);
    case ImageType.file:
      return Image.file(source, fit: BoxFit.contain);
    case ImageType.network:
    default:
      return Image.network(source, fit: BoxFit.contain);
  }
}
