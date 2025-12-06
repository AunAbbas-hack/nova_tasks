import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nova_tasks/core/utils/language/change_language.dart';
import 'package:nova_tasks/en_to_ur.dart';
import 'package:nova_tasks/features/auth/viewmodels/signup_viewmodel.dart';
import 'package:nova_tasks/features/me/presentation/viewmodels/settings_viewmodel.dart';
import 'package:nova_tasks/firebase_options.dart';
import 'package:provider/provider.dart';
import 'core/services/notificationservices/notification_services.dart';
import 'core/theme/app_theme.dart';
import 'features/startup/presentaion/views/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nova_tasks/l10n/app_localizations.dart';

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
  final settings=SettingsViewModel();
final initialLocale=Locale(settings.languageCode);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_)=>SettingsViewModel())
      ],
      child: NovaTasksApp(initialLocale: initialLocale,),
    ),
  );
}

class NovaTasksApp extends StatelessWidget {
  const NovaTasksApp({super.key,required this.initialLocale});
final Locale initialLocale;
  @override
  Widget build(BuildContext context) {
    final settings=Provider.of<SettingsViewModel  >(context);
    return Consumer(builder: (context,provider,child){
      return GetMaterialApp(
        locale: initialLocale,
        supportedLocales: const [
          Locale("en"),
          Locale("ur"),
        ],
        fallbackLocale: settings.locale,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          return settings.locale;
        },
        builder: (context,child){
          return Directionality(textDirection: settings.languageCode=="ur"?TextDirection.rtl:TextDirection.ltr,
              child: child??SizedBox.shrink());
        },
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'NovaTasks',
        theme: AppTheme.dark(),
        home: const SplashScreen(),
      );
    });
  }
}