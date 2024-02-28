import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:knightmotion/View/login.dart';
import 'package:provider/provider.dart';

class UserSignup extends StatefulWidget {
  @override
  State<UserSignup> createState() => _UserSignupState();
}

class _UserSignupState extends State<UserSignup> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String sname, semail, spassword;

  void saveToFirestore() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      try {
        await Firebase.initializeApp();
        // Save to authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: semail,
          password: spassword,
        );

        // Save to Firestore database
        final uid = userCredential.user!.uid;
        await FirebaseFirestore.instance.collection('UserSignup').doc(uid).set({
          'Name': sname,
          'Email': semail,
          'Password': spassword,
        }).then((result) {
          // Sign up successful
          Fluttertoast.showToast(
            msg: "Registration successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            timeInSecForIosWeb: 1,
            textColor: Colors.black,
            fontSize: 16.0,
          );
        });

        form.reset();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Fluttertoast.showToast(
              msg: "Too weak password",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.purple,
              timeInSecForIosWeb: 1,
              textColor: Colors.white,
              fontSize: 16.0);
        } else if (e.code == 'email-already-in-use') {
          Fluttertoast.showToast(
              msg: "Email already exists",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.purple,
              timeInSecForIosWeb: 1,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Error in saving data",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: 50),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/logo.png',
                  height: 150,
                  width: 150,
                  alignment: Alignment.centerLeft,
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create a new account',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Signup to continue',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 44.0),
              Form(
                key: _formKey,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 35, 0, 0),
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: "Enter your name",
                          hintStyle: TextStyle(color: Colors.black),
                          labelText: "Name",
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          prefixIcon: Icon(Icons.person, color: Colors.purple),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        onSaved: (value) => sname = value!,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "Enter your email",
                          hintStyle: TextStyle(color: Colors.black),
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          prefixIcon: Icon(Icons.mail, color: Colors.purple),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onSaved: (value) => semail = value!,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Enter your password",
                          hintStyle: TextStyle(color: Colors.black),
                          labelText: "Set Password",
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          prefixIcon: Icon(Icons.pin, color: Colors.purple),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onSaved: (value) => spassword = value!,
                      ),
                      SizedBox(height: 15),
                      RawMaterialButton(
                        padding: EdgeInsets.all(8),
                        fillColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        onPressed: () {
                          saveToFirestore();
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(100, 0, 100, 0),
                          child: Text(
                            "Next",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
