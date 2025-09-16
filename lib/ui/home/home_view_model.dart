import 'package:flutter/foundation.dart';
import '../../domain/use_cases/get_home_screen_data_use_case.dart';
import '../../domain/use_cases/log_emotion_use_case.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/community_article.dart';
import '../../domain/models/user_score.dart';

/// Home screen state enumeration
enum HomeState {
  initial,
  loading,
  loaded,
  error,
}

/// View model for home screen
class HomeViewModel extends ChangeNotifier {
  final GetHomeScreenDataUseCase _getHomeScreenDataUseCase;
  final LogEmotionUseCase _logEmotionUseCase;
  final String userId;
  final VoidCallback? onNavigateToKanhaChat;
  final Function(String)? onNavigateToActivity;
  final Function(String)? onNavigateToArticle;
  final VoidCallback? onNavigateToActivities;
  final VoidCallback? onNavigateToCommunity;

  HomeViewModel(
    this._getHomeScreenDataUseCase,
    this._logEmotionUseCase,
    this.userId, {
    this.onNavigateToKanhaChat,
    this.onNavigateToActivity,
    this.onNavigateToArticle,
    this.onNavigateToActivities,
    this.onNavigateToCommunity,
  }) {
    _loadHomeData();
  }

  HomeState _state = HomeState.initial;
  String? _errorMessage;
  
  // Home screen data
  String _userGreeting = 'Welcome!';
  String? _trustedContactInitial;
  String _aiWelcomeMessage = 'Hi! I\'m Kanha, your companion for emotional wellbeing.';
  List<Activity> _recommendedActivities = [];
  List<CommunityArticle> _featuredArticles = [];
  UserScore? _userScore;

  // Quick emotion logging
  bool _isLoggingEmotion = false;
  String? _emotionLogError;

  // Getters
  HomeState get state => _state;
  String? get errorMessage => _errorMessage;
  String get userGreeting => _userGreeting;
  String? get trustedContactInitial => _trustedContactInitial;
  String get aiWelcomeMessage => _aiWelcomeMessage;
  List<Activity> get recommendedActivities => _recommendedActivities;
  List<CommunityArticle> get featuredArticles => _featuredArticles;
  bool get isLoggingEmotion => _isLoggingEmotion;
  String? get emotionLogError => _emotionLogError;
  UserScore? get userScore => _userScore;

  /// Load home screen data
  Future<void> _loadHomeData() async {
    try {
      _setState(HomeState.loading);
      _clearError();

      final homeData = await _getHomeScreenDataUseCase.call(userId);
      
      _userGreeting = homeData.userGreeting;
      _trustedContactInitial = homeData.trustedContactInitial;
      _aiWelcomeMessage = homeData.aiWelcomeMessage;
      _recommendedActivities = homeData.recommendedActivities;
      _featuredArticles = homeData.featuredArticles;
      
      // TODO: Load user score from repository
      _userScore = const UserScore(
        userId: '',
        totalScore: 0,
        level: 1,
      );

      _setState(HomeState.loaded);
    } catch (e) {
      _setError('Failed to load home data: ${e.toString()}');
    }
  }

  /// Refresh home screen data
  Future<void> refresh() async {
    await _loadHomeData();
  }

  /// Quick log emotion method
  Future<void> logMood(String mood, int intensity, {String? note}) async {
    try {
      _setEmotionLoading(true);
      _clearEmotionError();

      final success = await _logEmotionUseCase.callSimple(
        userId: userId,
        mood: mood,
        intensity: intensity,
        note: note,
      );

      if (success) {
        // Refresh home data to get updated recommendations
        await refresh();
      } else {
        _setEmotionError('Failed to log emotion. Please try again.');
      }
    } catch (e) {
      _setEmotionError('An error occurred while logging your emotion.');
    } finally {
      _setEmotionLoading(false);
    }
  }

  /// Navigate to specific activity
  void onActivityTapped(Activity activity) {
    onNavigateToActivity?.call(activity.id);
  }

  /// Navigate to specific article
  void onArticleTapped(CommunityArticle article) {
    onNavigateToArticle?.call(article.id);
  }

  /// Navigate to AI chat
  void onAiChatTapped() {
    onNavigateToKanhaChat?.call();
  }

  /// Navigate to activities dashboard
  void onActivitiesTapped() {
    onNavigateToActivities?.call();
  }

  /// Navigate to community
  void onCommunityTapped() {
    onNavigateToCommunity?.call();
  }

  /// Navigate to trusted contact
  void onTrustedContactTapped() {
    // This would typically show contact options or navigate to contact screen
    debugPrint('Trusted contact tapped');
  }

  /// Set state
  void _setState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    _state = HomeState.error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Set emotion logging state
  void _setEmotionLoading(bool loading) {
    _isLoggingEmotion = loading;
    notifyListeners();
  }

  /// Set emotion log error
  void _setEmotionError(String message) {
    _emotionLogError = message;
    notifyListeners();
  }

  /// Clear emotion log error
  void _clearEmotionError() {
    _emotionLogError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}