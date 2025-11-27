import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nova_tasks/features/auth/viewmodels/signup_viewmodel.dart';
import 'package:nova_tasks/firebase_options.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/startup/presentaion/views/splash_screen.dart';

void main() async{
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform
);
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_)=>SignupViewModel()),

    ],child: const NovaTasksApp(),)
    
    
    
  );
}

class NovaTasksApp extends StatelessWidget {
  const NovaTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NovaTasks',
      theme: AppTheme.dark(),
      home: const SplashScreen(),
    );
  }
}
