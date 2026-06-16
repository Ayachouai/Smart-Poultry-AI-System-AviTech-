import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'signInSignUp.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PoultryGuardApp());
}

class PoultryGuardApp extends StatelessWidget {
  const PoultryGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AviTech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: '/signin',
      home: SignInScreen(),
      routes: {
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => const FarmerDashboard(),
      },
    );
  }
}
