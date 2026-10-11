import 'package:assignment_firebase_pushn_notification_local_notification/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

class AppStartup {
  static bool firebaseReady = false;
  static String firebaseError = '';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialize
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppStartup.firebaseReady = true;
  } catch (e) {
    AppStartup.firebaseError = e.toString();
  }
  // Google Sign-In initialize
  if (AppStartup.firebaseReady) {
    try {
      await GoogleSignIn.instance.initialize(
        clientId: '200125033244-s96buh49s29gad6r2b48ig8rb1g7aaur.apps.googleusercontent.com',
      );
    } catch (e) {
      debugPrint('Google Sign-In initialization error: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Task Manager',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5046E5)),
      ),
      home: const SplashScreen(),
    );
  }
}
