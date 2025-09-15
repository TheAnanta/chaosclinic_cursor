import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/dependency_injection.dart';
import 'firebase_options.dart';
import 'ui/core/themes/app_theme.dart';
import 'ui/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ChaosClinicApp());
}

class ChaosClinicApp extends StatelessWidget {
  const ChaosClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: DependencyInjection.getProviders(),
      child: MaterialApp(
        title: 'Chaos Clinic',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const AppRouter(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
