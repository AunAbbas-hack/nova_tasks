import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nova_tasks/features/auth/viewmodels/signup_viewmodel.dart';
import 'package:nova_tasks/firebase_options.dart';
import 'package:provider/provider.dart';

import 'core/services/notificationservices/notification_services.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/notification_utils.dart';  // ✅ Import your service
import 'features/startup/presentaion/views/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('🔔 Background FCM: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Initialize Push Notification Service
  await PushNotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
      ],
      child: const NovaTasksApp(),
    ),
  );
}

class NovaTasksApp extends StatelessWidget {
  const NovaTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'NovaTasks',
      theme: AppTheme.dark(),
      home: const SplashScreen(),
    );
  }
}