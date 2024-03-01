import 'package:flutter/material.dart';
import 'package:knightmotion/View/User/userDownloads.dart';
import 'package:knightmotion/View/User/userHome.dart';

class userBottom extends StatefulWidget {
  @override
  _userBottomState createState() => _userBottomState();
}

class _userBottomState extends State<userBottom> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    userHome(),
    userDownloads(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Templates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_rounded),
            label: 'Downloads',
          ),
        ],
      ),
    );
  }
}