import 'package:assignment_firebase_pushn_notification_local_notification/screen/add_task_screen.dart';
import 'package:assignment_firebase_pushn_notification_local_notification/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (__) => user == null
        ? const LoginScreen()
        : const TaskListScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 72,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.task_alt,
                size: 40,
                color: Color(0xFF5046E5),
              ),
            ),
            const Text(
              'Firebase Task Manager',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'A simple task manager powered by Flutter\n               & Firestore',
              selectionColor: Color(0xFF94A3B8),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 100),
            const CircularProgressIndicator(color: Color(0xFF5046E5), strokeWidth: 2),
            const SizedBox(height: 12),
            const Text(
              'Initializing app...',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            const SizedBox(height: 10),
            const Text(
              'Flutter Firebase ',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
