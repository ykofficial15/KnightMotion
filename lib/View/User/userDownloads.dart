import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:knightmotion/Controller/authentication.dart';
import 'package:knightmotion/View/User/fullImage.dart';
import 'package:knightmotion/View/login.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class userDownloads extends StatefulWidget {
  @override
  State<userDownloads> createState() => _userDownloadsState();
}

class _userDownloadsState extends State<userDownloads> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          // User is not logged in
          // You can handle this case accordingly, e.g., redirect to login screen
          return Center(
            child: Text('User not logged in'),
          );
        }
        final currentUser = snapshot.data!;
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
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('mytemplates')
                .where('userId', isEqualTo: currentUser.uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final List<DocumentSnapshot> documents = snapshot.data!.docs;
              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (BuildContext context, int index) {
                  final imageUrl = documents[index]['imageUrl'];
                  final documentId = documents[index].id;
                  return Card(
                    child: ListTile(
                      leading: Image.network(imageUrl,height: 100,width: 100,),
                      title: Text('Poster',style: TextStyle(color: Colors.purple),),
                      onTap: () => _showFullImagePreview(context, imageUrl),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.download),
                            onPressed: () => _downloadImage(context, imageUrl),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteImage(documentId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _downloadImage(BuildContext context, String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(response.bodyBytes);
    Fluttertoast.showToast(
      msg: "Image saved successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _deleteImage(String documentId) async {
    await FirebaseFirestore.instance.collection('mytemplates').doc(documentId).delete();
  }

  void _showFullImagePreview(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullImagePreview(imageUrl: imageUrl),
      ),
    );
  }
}
