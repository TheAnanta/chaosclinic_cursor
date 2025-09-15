import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/core/themes/app_theme.dart';

void main() {
  runApp(const ChaosClinicApp());
}

class ChaosClinicApp extends StatelessWidget {
  const ChaosClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers will be added here as we implement features
        // Provider<AuthenticationService>(
        //   create: (_) => FirebaseAuthenticationService(FirebaseAuth.instance),
        // ),
        // Provider<FirestoreService>(
        //   create: (_) => FirestoreService(FirebaseFirestore.instance),
        // ),
      ],
      child: MaterialApp(
        title: 'Chaos Clinic',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Temporary splash screen - will be replaced with proper onboarding/auth flow
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              ),
              child: const Icon(
                Icons.psychology,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Chaos Clinic',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Your companion for emotional wellbeing',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXXL),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
