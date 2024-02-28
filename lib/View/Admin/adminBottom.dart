import 'package:flutter/material.dart';
import 'package:knightmotion/Controller/authentication.dart';
import 'package:knightmotion/View/login.dart';
import 'package:provider/provider.dart';

class adminBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
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
      body: Center(
        child: Text('Welcome User!'),
      ),
    );
  }
}
