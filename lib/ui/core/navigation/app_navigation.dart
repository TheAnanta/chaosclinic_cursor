import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../kanha_chat/kanha_chat_screen.dart';
import '../kanha_chat/kanha_chat_view_model.dart';
import '../activities/word_search/word_search_screen.dart';
import '../activities/bug_smash/bug_smash_screen.dart';
import '../activities/meditation/meditation_screen.dart';
import '../activities/journaling/journal_screen.dart';
import '../activities/dashboard/activities_dashboard.dart';
import '../../domain/use_cases/kanha_chat_use_cases.dart';
import '../../domain/models/activity.dart';

/// Navigation helper for the app
class AppNavigation {
  /// Navigate to Kanha chat screen
  static void navigateToKanhaChat(BuildContext context, String userId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => KanhaChatViewModel(
            context.read<SendMessageToKanhaUseCase>(),
            context.read<GetChatHistoryUseCase>(),
            context.read<GetConversationStartersUseCase>(),
            userId,
          ),
          child: const KanhaChatScreen(),
        ),
      ),
    );
  }

  /// Navigate to activity screen (placeholder for future implementation)
  static void navigateToActivity(BuildContext context, String activityId) {
    // Navigate based on activity type or ID
    switch (activityId) {
      case '1': // Breathing meditation
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const MeditationScreen()),
        );
        break;
      case '2': // Word Search
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const WordSearchScreen()),
        );
        break;
      case '3': // Journaling
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const JournalScreen()),
        );
        break;
      default:
        _showComingSoonSnackBar(context, 'Activity');
    }
  }

  /// Navigate to community article (placeholder for future implementation)
  static void navigateToArticle(BuildContext context, String articleId) {
    // TODO: Implement article navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Article navigation coming soon!'),
      ),
    );
  }

  /// Navigate to activities dashboard (placeholder for future implementation)
  static void navigateToActivities(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ActivitiesDashboard()),
    );
  }

  /// Navigate to community feed (placeholder for future implementation)
  static void navigateToCommunity(BuildContext context) {
    _showComingSoonSnackBar(context, 'Community feed');
  }

  /// Show a "coming soon" snack bar
  static void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
      ),
    );
  }
}