import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ImageDetailPage extends StatefulWidget {
  final String backgroundImageUrl;
  ImageDetailPage(this.backgroundImageUrl);
  @override
  _ImageDetailPageState createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  File? _overlayImage;
  img.Image? _editedImage;
  double _overlayScale = 1.0;
  double _overlayLeft = 0.0;
  double _overlayTop = 0.0;
  double _overlayWidth = 0.0;
  double _overlayHeight = 0.0;
  double _initialScale = 1.0;
  double _initialX = 0.0;
  double _initialY = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Your Photo'),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_download_rounded),
            onPressed: _editedImage != null ? _saveImage : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (widget.backgroundImageUrl.isNotEmpty)
            Image.network(widget.backgroundImageUrl,width: MediaQuery.sizeOf(context).width),
          if (_overlayImage != null)
            Positioned(
              left: _overlayLeft,
              top: _overlayTop,
              child: GestureDetector(
                onScaleStart: (details) {
                  _initialScale = _overlayScale;
                  _initialX = details.focalPoint.dx - _overlayLeft;
                  _initialY = details.focalPoint.dy - _overlayTop;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _overlayScale = _initialScale * details.scale;
                    _overlayLeft =
                        details.focalPoint.dx - (_overlayScale * _initialX);
                    _overlayTop =
                        details.focalPoint.dy - (_overlayScale * _initialY);
                  });
                },
                onLongPress: () {
                  setState(() {
                    _overlayScale = 1.0;
                    _overlayLeft = 0.0;
                    _overlayTop = 0.0;
                  });
                },
                child: Container(
                  width: _overlayWidth * _overlayScale,
                  height: _overlayHeight * _overlayScale,
                  child:
                      _overlayImage != null ? Image.file(_overlayImage!) : null,
                ),
              ),
            ),
          Positioned(
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
            child: Slider(
              value: _overlayScale,
              min: 0.1, // Adjust the minimum scale here
              max: 2.0,
              onChanged: (value) {
                setState(() {
                  _overlayScale = value;
                });
              },
            ),
          ),
          
        ],

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectImage(ImageSource.gallery),
        tooltip: 'Select Overlay Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _overlayImage = File(pickedFile.path);
        _editedImage = img.decodeImage(_overlayImage!.readAsBytesSync());
        _setOverlaySize();
      });
    }
  }

  Future<void> _saveImage() async {
    if (_overlayImage == null || _editedImage == null) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    // Load background image
    final backgroundImageBytes = await NetworkAssetBundle(Uri.parse(widget.backgroundImageUrl)).load('');
    final backgroundImage = img.decodeImage(backgroundImageBytes.buffer.asUint8List());

    // Scale overlay image to match its position
    final scaledOverlayImage = img.copyResize(_editedImage!, width: (_overlayWidth * _overlayScale).toInt(), height: (_overlayHeight * _overlayScale).toInt());

    // Create a new image to merge the background and overlay images
    final mergedImage = img.Image(width:backgroundImage!.width, height:backgroundImage.height);

    // Draw the background image onto the merged image
    _drawImage(mergedImage, backgroundImage, 0, 0);

    // Draw the overlay image onto the merged image at the specified position
    _drawImage(mergedImage, scaledOverlayImage, _overlayLeft.toInt(), _overlayTop.toInt());

    // Save the merged image
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/merged_image.png';
    File(path).writeAsBytesSync(img.encodePng(mergedImage));

    // Upload merged image to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('images').child('merged_image.png');
    final uploadTask = storageRef.putFile(File(path));
    final TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() => null);
    final imageUrl = await storageTaskSnapshot.ref.getDownloadURL();

    // Save merged image URL to Firestore with current user UID
    await FirebaseFirestore.instance.collection('mytemplates').add({
      'imageUrl': imageUrl,
      'userId': currentUser.uid,
    });

    // Show toast message
    Fluttertoast.showToast(
      msg: 'Image saved successfully!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  void _drawImage(img.Image dest, img.Image src, int x, int y) {
    for (int sy = 0; sy < src.height; sy++) {
      for (int sx = 0; sx < src.width; sx++) {
        img.Pixel c = src.getPixel(sx, sy);
        dest.setPixel(x + sx, y + sy, c);
      }
    }
  }

  void _setOverlaySize() async {
    final image = img.decodeImage(await _overlayImage!.readAsBytes());
    if (image != null) {
      setState(() {
        _overlayWidth = image.width.toDouble();
        _overlayHeight = image.height.toDouble();
      });
    }
  }
}
