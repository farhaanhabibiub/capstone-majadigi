import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_route.dart';
import 'firebase_options.dart';
import 'notification_service.dart';
import 'theme/theme_controller.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  await NotificationService.initialize();
  await ThemeController.init();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((message) {
    if (message.notification != null) {
      NotificationService.showStatusUpdateNotification(
        tiketId: message.data['tiketId'] ?? '',
        newStatus: message.data['status'] ?? message.notification!.body ?? '',
      );
    }
  });

  _saveFcmToken();

  runApp(const MyApp());
}

Future<void> _saveFcmToken() async {
  try {
    await FirebaseMessaging.instance.requestPermission();
    final token = await FirebaseMessaging.instance.getToken();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (token != null && uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'fcmToken': token, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null) {
        await FirebaseFirestore.instance.collection('users').doc(currentUid).set(
          {'fcmToken': newToken, 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
      }
    });
  } catch (_) {}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.notifier,
      builder: (_, themeMode, __) => MaterialApp(
        title: 'Majadigi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF0065FF),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0065FF)),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: const Color(0xFF0065FF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0065FF),
            brightness: Brightness.dark,
          ),
        ),
        themeMode: themeMode,
        initialRoute: AppRoutes.splashScreen,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
