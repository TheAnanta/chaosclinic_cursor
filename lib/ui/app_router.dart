import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../authentication/authentication_view_model.dart';
import '../onboarding/onboarding_view_model.dart';
import '../home/home_view_model.dart';
import '../authentication/authentication_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/home_screen.dart';
import '../../domain/use_cases/submit_onboarding_use_case.dart';
import '../../domain/use_cases/get_home_screen_data_use_case.dart';
import '../../domain/use_cases/log_emotion_use_case.dart';

/// Main app router that manages navigation between authentication, onboarding, and main app
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationViewModel>(
      builder: (context, authViewModel, child) {
        // Show loading screen while authentication state is being determined
        if (authViewModel.state == AuthState.initial) {
          return const _LoadingScreen();
        }

        // User is not authenticated - show authentication screen
        if (!authViewModel.isAuthenticated) {
          return const AuthenticationScreen();
        }

        // User is authenticated - check if onboarding is needed
        final user = authViewModel.currentUser;
        if (user == null) {
          return const AuthenticationScreen();
        }

        // User has not completed onboarding - show onboarding flow
        if (!user.hasCompletedOnboarding) {
          return ChangeNotifierProvider(
            create: (context) => OnboardingViewModel(
              context.read<SubmitOnboardingUseCase>(),
              user.uid,
            ),
            child: OnboardingScreen(userId: user.uid),
          );
        }

        // User is authenticated and has completed onboarding - show main app
        return ChangeNotifierProvider(
          create: (context) => HomeViewModel(
            context.read<GetHomeScreenDataUseCase>(),
            context.read<LogEmotionUseCase>(),
            user.uid,
          ),
          child: HomeScreen(user: user),
        );
      },
    );
  }
}

/// Simple loading screen shown while determining authentication state
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}