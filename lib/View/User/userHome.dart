import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:knightmotion/Controller/authentication.dart';
import 'package:knightmotion/Controller/userHomeController.dart';
import 'package:knightmotion/Model/userHomeModel.dart';
import 'package:knightmotion/View/User/userImagePreview.dart';
import 'package:knightmotion/View/login.dart';
import 'package:provider/provider.dart';

class userHome extends StatefulWidget {
  @override
  State<userHome> createState() => _userHomeState();
}
class _userHomeState extends State<userHome> {
  @override
  Widget build(BuildContext context) {
    final eventController = Provider.of<EventController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('User Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<Authenticate>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Login()));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: eventController.fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          } else {
            final events = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              itemCount: events.length,
              itemBuilder: (BuildContext context, int index) {
                final event = events[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetailPage(event.imageUrl),
                      ),
                    );
                  },
                  child: Container(
                    height: 200, // Set a fixed height for the card
                    child: Card(
                      elevation: 3,
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              event.imageUrl,
                              fit: BoxFit.cover, // Ensure images are of the same size
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(event.eventName),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _uploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Handle image upload
      // You can implement your logic here to upload the image
    }
  }
}
