import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app_route.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Majadigi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF007AFF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
      ),
      // initialRoute: AppRoutes.openDataLandingPage,
      // initialRoute: AppRoutes.klinikHoaksPermohonanPage,
      initialRoute: AppRoutes.nomorDaruratLandingPage,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
