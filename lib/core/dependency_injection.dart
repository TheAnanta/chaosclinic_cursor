import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Services
import '../data/services/authentication_service.dart';
import '../data/services/firestore_service.dart';
import '../data/services/health_platform_service.dart';

// Repositories
import '../data/repositories/user_repository.dart';
import '../data/repositories/user_repository_impl.dart';
import '../data/repositories/emotion_repository.dart';
import '../data/repositories/emotion_repository_impl.dart';
import '../data/repositories/activity_repository.dart';
import '../data/repositories/community_repository.dart';

// Use Cases
import '../domain/use_cases/log_emotion_use_case.dart';
import '../domain/use_cases/get_personalized_activity_use_case.dart';
import '../domain/use_cases/get_home_screen_data_use_case.dart';
import '../domain/use_cases/submit_onboarding_use_case.dart';

// Domain Models
import '../domain/models/activity.dart';
import '../domain/models/community_article.dart';

// View Models
import '../ui/authentication/authentication_view_model.dart';

/// Dependency injection setup for the app
class DependencyInjection {
  /// Get list of providers for the app
  static List<SingleChildWidget> getProviders() {
    return [
      // Firebase services (these would normally be initialized in main.dart)
      Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
      Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),
      
      // Core services
      Provider<AuthenticationService>(
        create: (context) => FirebaseAuthenticationService(
          context.read<FirebaseAuth>(),
        ),
      ),
      Provider<FirestoreService>(
        create: (context) => FirestoreService(
          context.read<FirebaseFirestore>(),
        ),
      ),
      Provider<HealthPlatformService>(
        create: (context) => HealthPlatformServiceImpl(),
      ),
      
      // Repositories
      Provider<UserRepository>(
        create: (context) => UserRepositoryImpl(
          context.read<FirestoreService>(),
        ),
      ),
      Provider<EmotionRepository>(
        create: (context) => EmotionRepositoryImpl(
          context.read<FirestoreService>(),
          context.read<HealthPlatformService>(),
        ),
      ),
      
      // Mock implementations for repositories that aren't fully implemented yet
      Provider<ActivityRepository>(
        create: (context) => MockActivityRepository(),
      ),
      Provider<CommunityRepository>(
        create: (context) => MockCommunityRepository(),
      ),
      
      // Use cases
      Provider<LogEmotionUseCase>(
        create: (context) => LogEmotionUseCase(
          context.read<EmotionRepository>(),
        ),
      ),
      Provider<GetPersonalizedActivityUseCase>(
        create: (context) => GetPersonalizedActivityUseCase(
          context.read<UserRepository>(),
          context.read<ActivityRepository>(),
        ),
      ),
      Provider<GetHomeScreenDataUseCase>(
        create: (context) => GetHomeScreenDataUseCase(
          context.read<UserRepository>(),
          context.read<ActivityRepository>(),
          context.read<CommunityRepository>(),
        ),
      ),
      Provider<SubmitOnboardingUseCase>(
        create: (context) => SubmitOnboardingUseCase(
          context.read<UserRepository>(),
        ),
      ),
      
      // View models
      ChangeNotifierProvider<AuthenticationViewModel>(
        create: (context) => AuthenticationViewModel(
          context.read<AuthenticationService>(),
          context.read<UserRepository>(),
        ),
      ),
    ];
  }
}

// Mock implementations for repositories that aren't fully built yet
class MockActivityRepository implements ActivityRepository {
  @override
  Future<List<Activity>> getAllActivities() async {
    return _getMockActivities();
  }

  @override
  Future<Activity?> getActivity(String activityId) async {
    final activities = await getAllActivities();
    return activities.cast<Activity?>().firstWhere(
      (activity) => activity?.id == activityId,
      orElse: () => null,
    );
  }

  @override
  Future<Activity?> getRecommendedActivity({String? targetMood, double? difficultyLevel}) async {
    final activities = await getAllActivities();
    return activities.isNotEmpty ? activities.first : null;
  }

  @override
  Future<List<Activity>> getRecommendedActivities({
    List<String>? targetMoods,
    double? difficultyLevel,
    int limit = 5,
  }) async {
    final activities = await getAllActivities();
    return activities.take(limit).toList();
  }

  @override
  Future<List<Activity>> getRecommendedActivitiesForUser(String userId, {int limit = 5}) async {
    return getRecommendedActivities(limit: limit);
  }

  @override
  Future<List<Activity>> getActivitiesByType(ActivityType type, {int? limit}) async {
    final activities = await getAllActivities();
    final filtered = activities.where((activity) => activity.type == type).toList();
    return limit != null ? filtered.take(limit).toList() : filtered;
  }

  @override
  Future<List<Activity>> getActivitiesByDifficulty(double difficultyLevel, {int limit = 5}) async {
    final activities = await getAllActivities();
    return activities.take(limit).toList();
  }

  @override
  Future<void> markActivityCompleted(String userId, String activityId) async {
    // Mock implementation
  }

  @override
  Future<List<Activity>> getCompletedActivities(String userId) async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getActivityHistory(String userId) async {
    return [];
  }

  @override
  Future<void> saveActivityProgress(String userId, String activityId, Map<String, dynamic> progressData) async {
    // Mock implementation
  }

  @override
  Future<Map<String, dynamic>?> getActivityProgress(String userId, String activityId) async {
    return null;
  }

  List<Activity> _getMockActivities() {
    return [
      Activity(
        id: '1',
        title: 'Mindful Breathing',
        description: 'A 5-minute guided breathing exercise to help you relax',
        type: ActivityType.breathing,
        assetPath: 'assets/activities/breathing.json',
        estimatedDurationMinutes: 5,
        benefits: ['Reduces stress', 'Improves focus'],
        targetEmotions: ['anxious', 'stressed'],
        difficultyLevel: 0.2,
      ),
      Activity(
        id: '2',
        title: 'Word Search',
        description: 'Find hidden words in this relaxing puzzle game',
        type: ActivityType.game,
        assetPath: 'assets/activities/word_search.json',
        estimatedDurationMinutes: 10,
        benefits: ['Improves focus', 'Reduces anxiety'],
        targetEmotions: ['bored', 'restless'],
        difficultyLevel: 0.4,
      ),
      Activity(
        id: '3',
        title: 'Gratitude Journal',
        description: 'Write down three things you\'re grateful for today',
        type: ActivityType.journaling,
        assetPath: 'assets/activities/journaling.json',
        estimatedDurationMinutes: 10,
        benefits: ['Improves mood', 'Increases positivity'],
        targetEmotions: ['sad', 'down'],
        difficultyLevel: 0.3,
      ),
    ];
  }
}

class MockCommunityRepository implements CommunityRepository {
  @override
  Future<List<CommunityArticle>> getAllArticles({int? limit}) async {
    return _getMockArticles();
  }

  @override
  Future<CommunityArticle?> getArticle(String articleId) async {
    final articles = await getAllArticles();
    return articles.cast<CommunityArticle?>().firstWhere(
      (article) => article?.id == articleId,
      orElse: () => null,
    );
  }

  @override
  Future<List<CommunityArticle>> getFeaturedArticles({int limit = 5}) async {
    final articles = await getAllArticles();
    return articles.take(limit).toList();
  }

  @override
  Future<List<CommunityArticle>> getArticlesByCategory(String category, {int? limit}) async {
    final articles = await getAllArticles();
    return limit != null ? articles.take(limit).toList() : articles;
  }

  @override
  Future<List<CommunityArticle>> getArticlesByTags(List<String> tags, {int? limit}) async {
    final articles = await getAllArticles();
    return limit != null ? articles.take(limit).toList() : articles;
  }

  @override
  Future<List<CommunityArticle>> searchArticles(String query, {int? limit}) async {
    final articles = await getAllArticles();
    return limit != null ? articles.take(limit).toList() : articles;
  }

  @override
  Future<List<CommunityArticle>> getRecentArticles({int limit = 10}) async {
    final articles = await getAllArticles();
    return articles.take(limit).toList();
  }

  @override
  Future<List<CommunityArticle>> getPopularArticles({int limit = 10}) async {
    final articles = await getAllArticles();
    return articles.take(limit).toList();
  }

  @override
  Future<void> likeArticle(String userId, String articleId) async {}

  @override
  Future<void> unlikeArticle(String userId, String articleId) async {}

  @override
  Future<void> bookmarkArticle(String userId, String articleId) async {}

  @override
  Future<void> removeBookmark(String userId, String articleId) async {}

  @override
  Future<List<CommunityArticle>> getBookmarkedArticles(String userId) async {
    return [];
  }

  @override
  Future<List<CommunityArticle>> getLikedArticles(String userId) async {
    return [];
  }

  @override
  Future<void> incrementViewCount(String articleId) async {}

  @override
  Future<List<CommunityArticle>> getPersonalizedArticles(String userId, {int limit = 5}) async {
    final articles = await getAllArticles();
    return articles.take(limit).toList();
  }

  List<CommunityArticle> _getMockArticles() {
    return [
      CommunityArticle(
        id: '1',
        title: '5 Simple Ways to Manage Daily Stress',
        subtitle: 'Practical tips for a calmer day',
        authorName: 'Dr. Sarah Johnson',
        authorImageUrl: 'https://example.com/avatar1.jpg',
        headerImageUrl: 'https://example.com/header1.jpg',
        content: 'Stress is a natural part of life, but managing it effectively is key to maintaining your wellbeing...',
        tags: ['stress', 'management', 'wellness'],
        readTimeInMinutes: 5,
        likes: 124,
        views: 1250,
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Wellness',
      ),
      CommunityArticle(
        id: '2',
        title: 'The Science of Gratitude',
        subtitle: 'How appreciation changes your brain',
        authorName: 'Dr. Michael Chen',
        authorImageUrl: 'https://example.com/avatar2.jpg',
        headerImageUrl: 'https://example.com/header2.jpg',
        content: 'Research shows that practicing gratitude can actually rewire your brain for positivity...',
        tags: ['gratitude', 'science', 'positivity'],
        readTimeInMinutes: 7,
        likes: 89,
        views: 890,
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        category: 'Science',
      ),
      CommunityArticle(
        id: '3',
        title: 'Building Healthy Sleep Habits',
        subtitle: 'Your guide to better rest',
        authorName: 'Sleep Specialist Team',
        authorImageUrl: 'https://example.com/avatar3.jpg',
        headerImageUrl: 'https://example.com/header3.jpg',
        content: 'Quality sleep is fundamental to mental health. Here are proven strategies to improve your sleep...',
        tags: ['sleep', 'health', 'habits'],
        readTimeInMinutes: 6,
        likes: 156,
        views: 2100,
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Health',
      ),
    ];
  }
}