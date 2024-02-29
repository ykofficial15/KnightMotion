import 'package:flutter/material.dart';
import 'package:knightmotion/Controller/authentication.dart';
import 'package:knightmotion/View/Admin/adminHome.dart';
import 'package:knightmotion/View/login.dart';
import 'package:provider/provider.dart';

class adminBottom extends StatefulWidget {
  @override
  _adminBottomState createState() => _adminBottomState();
}

class _adminBottomState extends State<adminBottom> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    adminHome(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'Status',
          ),
        ],
      ),
    );
  }
}
