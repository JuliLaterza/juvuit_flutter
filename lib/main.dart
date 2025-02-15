import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WIT Ü',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login, // Ruta inicial
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
