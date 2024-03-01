import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:knightmotion/Controller/authentication.dart';
import 'package:knightmotion/View/login.dart';
import 'package:provider/provider.dart';

class adminHome extends StatefulWidget {
  @override
  _adminHomeState createState() => _adminHomeState();
}

class _adminHomeState extends State<adminHome> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? _image;
  String? _selectedEvent;
  late String ename;
  late String uid;

  @override
  void initState() {
    super.initState();
    getUserID();
  }

  void getUserID() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        uid = currentUser.uid;
      });
    }
  }

  void _submitForm() async {
    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        //------------------------------------------------------------ Event Launched

        if (_image == null) {
          Fluttertoast.showToast(
            msg: 'Please select a template',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }

        // Upload image to Firebase Storage
        final Reference ref =
            _storage.ref().child('template_images/${DateTime.now().toString()}');
        final TaskSnapshot uploadTask = await ref.putFile(_image!);
        final imageUrl = await uploadTask.ref.getDownloadURL();

        // Save form data to Firestore
        await _firestore.collection('Template').add({
          'eventName': ename,
          'uid': uid,
          'image_url': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Template Launched Successfully!')),
        );

        Fluttertoast.showToast(
          msg: 'Template Launched',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // Clear form fields after successful submission
        _formKey.currentState!.reset();
        setState(() {
          _image = null;
        });
      } else {
        Fluttertoast.showToast(
          msg: 'Failed To Launch!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      print('Error saving data: $e');
      Fluttertoast.showToast(
        msg: 'Error saving data',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Please add a template',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text('Admin Home'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(13, 255, 0, 242),
                  ),
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  alignment: Alignment.center,
                  width: (MediaQuery.of(context).size.width),
                  child: Text(
                    'ADD TEMPLATE',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 60),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Template Name',
                    hintText: 'Enter Your Template Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the template name';
                    }
                    return null;
                  },
                  onSaved: (value) => ename = value!,
                ),
                SizedBox(height: 20),
               
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: _image != null
                      ? Image.file(_image!)
                      : Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.purple),
                            color: Color.fromARGB(108, 243, 79, 255),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 50,
                          ),
                        ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Upload Template'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
