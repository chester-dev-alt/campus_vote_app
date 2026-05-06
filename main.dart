import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 🔥 ADD THIS
import 'routes/app_routes.dart';
import 'firebase_options.dart';
void main() async {
  // 🔥 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 2. Initialize Firebase
  await Firebase.initializeApp();

  runApp(const CampusVoteApp());
}

class CampusVoteApp extends StatelessWidget {
  const CampusVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Vote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: AppRoutes.router,
    );
  }
}