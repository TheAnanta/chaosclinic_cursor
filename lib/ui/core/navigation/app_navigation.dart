import 'package:flutter/material.dart';

import '../../activities/dashboard/activities_dashboard.dart';
import '../../activities/journaling/journal_screen.dart';
import '../../activities/word_search/word_search_screen.dart';
import '../../activities/meditation/meditation_screen.dart';
import '../../activities/bug_smash/bug_smash_screen.dart';
import '../../activities/breathing_exercises_screen.dart';
import '../../activities/gratitude/gratitude_screen.dart';
import '../../emotion_log/emotion_log_screen.dart';
import '../../community/community_screen.dart';
import '../../kanha_chat/kanha_chat_screen.dart';

/// Navigation helper for the app
class AppNavigation {
  /// Navigate to Kanha chat screen
  static void navigateToKanhaChat(BuildContext context, String userId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const KanhaChatScreen(),
      ),
    );
  }

  /// Navigate to activity screen based on activity type
  static void navigateToActivity(BuildContext context, String activityId) {
    Widget screen;
    switch (activityId.toLowerCase()) {
      case 'journal':
      case 'journaling':
        screen = const JournalScreen();
        break;
      case 'gratitude':
      case 'gratitude_practice':
        screen = const GratitudeScreen();
        break;
      case 'wordsearch':
      case 'word_search':
        screen = const WordSearchScreen();
        break;
      case 'meditation':
        screen = const MeditationScreen();
        break;
      case 'breathing':
      case 'breathing_exercises':
        screen = const BreathingExercisesScreen();
        break;
      case 'bugsmash':
      case 'bug_smash':
        screen = const BugSmashScreen();
        break;
      case 'emotion_log':
      case 'emotions':
        screen = const EmotionLogScreen();
        break;
      default:
        _showComingSoonSnackBar(context, 'Activity: $activityId');
        return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => screen),
    );
  }

  /// Navigate to community article (placeholder for future implementation)
  static void navigateToArticle(BuildContext context, String articleId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Article navigation coming soon!'),
      ),
    );
  }

  /// Navigate to activities dashboard
  static void navigateToActivities(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const ActivitiesDashboard(),
      ),
    );
  }

  /// Navigate to community feed (placeholder for future implementation)
  static void navigateToCommunity(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const CommunityScreen(),
      ),
    );
  }

  /// Navigate directly to journal screen
  static void navigateToJournal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const JournalScreen(),
      ),
    );
  }

  /// Navigate directly to word search screen
  static void navigateToWordSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const WordSearchScreen(),
      ),
    );
  }

  /// Navigate directly to meditation screen
  static void navigateToMeditation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const MeditationScreen(),
      ),
    );
  }

  /// Navigate directly to bug smash screen
  static void navigateToBugSmash(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const BugSmashScreen(),
      ),
    );
  }

  /// Navigate directly to gratitude screen
  static void navigateToGratitude(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const GratitudeScreen(),
      ),
    );
  }

  /// Navigate directly to emotion log screen
  static void navigateToEmotionLog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const EmotionLogScreen(),
      ),
    );
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