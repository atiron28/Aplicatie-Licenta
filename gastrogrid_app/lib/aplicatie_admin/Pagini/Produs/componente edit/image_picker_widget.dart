import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImagePickerWidget extends StatelessWidget {
  final Uint8List? imageData;
  final String? imageUrl;
  final VoidCallback onImagePicked;

  const ImagePickerWidget({super.key, this.imageData, this.imageUrl, required this.onImagePicked});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        imageData != null
            ? Image.memory(imageData!, height: 150)
            : imageUrl != null
                ? Image.network(
                    imageUrl!,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: Center(child: Text('-')),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: Center(child: Text('-')),
                  ),
        SizedBox(height: 16),
        TextButton.icon(
          onPressed: onImagePicked,
          icon: Icon(Icons.image),
          label: Text('Schimba Imaginea'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueGrey[900],
          ),
        ),
      ],
    );
  }
}
