import '../models/user_profile.dart';
import '../models/activity.dart';
import '../models/community_article.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/community_repository.dart';

/// Combined data model for home screen
class HomeScreenData {
  final String userGreeting;
  final String? trustedContactInitial;
  final String aiWelcomeMessage;
  final List<Activity> recommendedActivities;
  final List<CommunityArticle> featuredArticles;
  final UserProfile? userProfile;

  HomeScreenData({
    required this.userGreeting,
    this.trustedContactInitial,
    required this.aiWelcomeMessage,
    required this.recommendedActivities,
    required this.featuredArticles,
    this.userProfile,
  });
}

/// Use case for getting all data needed for the home screen
class GetHomeScreenDataUseCase {
  final UserRepository _userRepository;
  final ActivityRepository _activityRepository;
  final CommunityRepository _communityRepository;

  GetHomeScreenDataUseCase(
    this._userRepository,
    this._activityRepository,
    this._communityRepository,
  );

  /// Get complete home screen data for a user
  Future<HomeScreenData> call(String userId) async {
    try {
      // Fetch user profile
      final userProfile = await _userRepository.getUserProfile(userId);
      
      // Get user greeting based on time of day and recent mood
      final greeting = await _generateUserGreeting(userId, userProfile);
      
      // Get trusted contact initial
      final trustedContactInitial = _getTrustedContactInitial(userProfile);
      
      // Generate AI welcome message
      final aiMessage = await _generateAIWelcomeMessage(userId, userProfile);
      
      // Get recommended activities (3-5 activities)
      final recommendedActivities = await _activityRepository.getRecommendedActivitiesForUser(
        userId,
        limit: 4,
      );
      
      // Get featured community articles
      final featuredArticles = await _communityRepository.getFeaturedArticles(limit: 3);

      return HomeScreenData(
        userGreeting: greeting,
        trustedContactInitial: trustedContactInitial,
        aiWelcomeMessage: aiMessage,
        recommendedActivities: recommendedActivities,
        featuredArticles: featuredArticles,
        userProfile: userProfile,
      );
    } catch (e) {
      // Return default data if there's an error
      return _getDefaultHomeScreenData();
    }
  }

  /// Generate personalized greeting based on time of day and user data
  Future<String> _generateUserGreeting(String userId, UserProfile? profile) async {
    final hour = DateTime.now().hour;
    final timeOfDay = hour < 12 ? 'morning' : (hour < 17 ? 'afternoon' : 'evening');
    
    final name = profile?.displayName.split(' ').first ?? 'there';
    
    // Get recent emotion for more personalized greeting
    final recentEmotions = await _userRepository.getRecentEmotionLogs(userId, limit: 1);
    
    if (recentEmotions.isNotEmpty) {
      final latestMood = recentEmotions.first.mood.toLowerCase();
      
      switch (latestMood) {
        case 'happy':
        case 'joyful':
        case 'excited':
          return 'Good $timeOfDay, $name! You seem to be in great spirits! 🌟';
        case 'sad':
        case 'down':
        case 'depressed':
          return 'Good $timeOfDay, $name. I hope today brings you some peace 💙';
        case 'anxious':
        case 'worried':
        case 'stressed':
          return 'Good $timeOfDay, $name. Let\'s take things one step at a time 🌱';
        case 'angry':
        case 'frustrated':
        case 'irritated':
          return 'Good $timeOfDay, $name. Take a deep breath - you\'ve got this 💪';
        default:
          return 'Good $timeOfDay, $name! How are you feeling today?';
      }
    }
    
    return 'Good $timeOfDay, $name! How are you feeling today?';
  }

  /// Get first initial of primary trusted contact
  String? _getTrustedContactInitial(UserProfile? profile) {
    if (profile?.supportContacts.isEmpty ?? true) return null;
    
    final primaryContact = profile!.supportContacts.firstWhere(
      (contact) => contact.isPrimary,
      orElse: () => profile.supportContacts.first,
    );
    
    return primaryContact.name.isNotEmpty ? primaryContact.name[0].toUpperCase() : null;
  }

  /// Generate AI welcome message based on user's current state
  Future<String> _generateAIWelcomeMessage(String userId, UserProfile? profile) async {
    final recentEmotions = await _userRepository.getRecentEmotionLogs(userId, limit: 3);
    
    if (recentEmotions.isEmpty) {
      return "Hi! I'm Kanha, your companion for emotional wellbeing. How are you feeling today?";
    }
    
    // Analyze recent emotional patterns
    final averageIntensity = recentEmotions.fold<double>(
      0.0,
      (sum, log) => sum + log.intensity,
    ) / recentEmotions.length;
    
    if (averageIntensity >= 4.0) {
      return "I notice you've been experiencing some intense emotions lately. Remember, it's okay to feel deeply. Would you like to try a calming activity?";
    } else if (averageIntensity <= 2.0) {
      return "I see you've been in a more reflective space recently. Sometimes gentle activities can help lift our spirits. What sounds good to you today?";
    } else {
      return "It looks like you're finding your balance. That's wonderful! I'm here if you'd like to explore some activities together.";
    }
  }

  /// Return default home screen data in case of errors
  HomeScreenData _getDefaultHomeScreenData() {
    return HomeScreenData(
      userGreeting: 'Welcome! How are you feeling today?',
      trustedContactInitial: null,
      aiWelcomeMessage: "Hi! I'm Kanha, your companion for emotional wellbeing. How are you feeling today?",
      recommendedActivities: [],
      featuredArticles: [],
      userProfile: null,
    );
  }
}