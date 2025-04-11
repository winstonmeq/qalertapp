import 'package:flutter/material.dart';

class ImagePage extends StatelessWidget {
  final String imageUrl;

  ImagePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported Image'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Allows panning
          scaleEnabled: true, // Allows zooming
          minScale: 0.5, // Minimum zoom level
          maxScale: 4.0, // Maximum zoom level
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain, // Shows full image, maintains aspect ratio
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 50,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}