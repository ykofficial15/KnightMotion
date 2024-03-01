
import 'package:flutter/material.dart';

class FullImagePreview extends StatefulWidget {
  final String imageUrl;

  FullImagePreview({required this.imageUrl});

  @override
  State<FullImagePreview> createState() => _FullImagePreviewState();
}

class _FullImagePreviewState extends State<FullImagePreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Image Preview'),
      ),
      body: Center(
        child: Image.network(widget.imageUrl),
      ),
    );
  }
}
