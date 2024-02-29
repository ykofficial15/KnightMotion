import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:knightmotion/Controller/authentication.dart';
import 'package:knightmotion/View/Admin/adminBottom.dart';
import 'package:knightmotion/View/User/userBottom.dart';
import 'package:knightmotion/View/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyBvEt7DfMmkRbJdwPgHAYl76hCoGqa31n4',
      appId: '1:473899416241:android:55a409aab6e4c9b4680090',
      messagingSenderId: '473899416241', 
      projectId: 'knightmotion-8fa01',
      storageBucket: 'gs://knightmotion-8fa01.appspot.com',
    ),
  );

runApp(
    MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => Authenticate()),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ),
)
  );
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'Flutter Login App',
        home: AnimatedSplashScreen(
                duration: 3000,
                splash: Image.asset('assets/logo.png'),
                splashIconSize: 300,
                nextScreen:SplashScreen(),
              ),
      );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 0), () async {
      await Provider.of<Authenticate>(context, listen: false).checkLoginStatus();
      _navigateToCorrectScreen(context);
    });

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _navigateToCorrectScreen(BuildContext context) {
    final authProvider = Provider.of<Authenticate>(context, listen: false);
    if (authProvider.userLoggedIn) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => UserBottom()));
    } else if (authProvider.adminLoggedIn) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => adminBottom()));
    } else {
      // Navigate to login screen if neither user nor admin is logged in
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Login()));
    }
  }
}

