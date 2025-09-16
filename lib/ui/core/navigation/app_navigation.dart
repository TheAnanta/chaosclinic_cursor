import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../kanha_chat/kanha_chat_screen.dart';
import '../kanha_chat/kanha_chat_view_model.dart';
import '../../domain/use_cases/kanha_chat_use_cases.dart';

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
    // TODO: Implement activity navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Activity navigation coming soon!'),
      ),
    );
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
    // TODO: Implement activities dashboard navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Activities dashboard coming soon!'),
      ),
    );
  }

  /// Navigate to community feed (placeholder for future implementation)
  static void navigateToCommunity(BuildContext context) {
    // TODO: Implement community feed navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Community feed coming soon!'),
      ),
    );
  }
}