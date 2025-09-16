import 'package:flutter/material.dart';
import '../../domain/models/user_score.dart';

/// Leaderboard user model extending UserScore
class LeaderboardUser extends UserScore {
  final int rank;
  
  const LeaderboardUser({
    required super.userId,
    required super.totalScore,
    required super.gameScore,
    required super.meditationScore,
    required super.journalScore,
    required super.gratitudeScore,
    required super.emotionLogScore,
    required super.activitiesCompleted,
    required super.streakDays,
    required this.rank,
    super.lastActivityAt,
    super.createdAt,
    super.updatedAt,
    required String username,
  }) : _username = username;

  final String _username;
  
  String get username => _username;
}

/// View model for leaderboard screen
class LeaderboardViewModel extends ChangeNotifier {
  List<LeaderboardUser> _leaderboardUsers = [];
  LeaderboardUser? _currentUserRank;
  bool _isLoading = false;

  // Getters
  List<LeaderboardUser> get leaderboardUsers => _leaderboardUsers;
  LeaderboardUser? get currentUserRank => _currentUserRank;
  bool get isLoading => _isLoading;

  LeaderboardViewModel() {
    _initializeLeaderboard();
  }

  void _initializeLeaderboard() {
    // Sample leaderboard data
    _leaderboardUsers = [
      const LeaderboardUser(
        userId: 'user1',
        username: 'MindfulMaster',
        totalScore: 15420,
        gameScore: 5200,
        meditationScore: 7500,
        journalScore: 1920,
        gratitudeScore: 800,
        emotionLogScore: 0,
        activitiesCompleted: 142,
        streakDays: 28,
        rank: 1,
      ),
      const LeaderboardUser(
        userId: 'user2',
        username: 'ZenWarrior',
        totalScore: 12850,
        gameScore: 4800,
        meditationScore: 6200,
        journalScore: 1450,
        gratitudeScore: 400,
        emotionLogScore: 0,
        activitiesCompleted: 118,
        streakDays: 21,
        rank: 2,
      ),
      const LeaderboardUser(
        userId: 'user3',
        username: 'WellnessChamp',
        totalScore: 11200,
        gameScore: 3900,
        meditationScore: 5100,
        journalScore: 1800,
        gratitudeScore: 400,
        emotionLogScore: 0,
        activitiesCompleted: 95,
        streakDays: 16,
        rank: 3,
      ),
      const LeaderboardUser(
        userId: 'user4',
        username: 'CalmSeeker',
        totalScore: 9850,
        gameScore: 3200,
        meditationScore: 4800,
        journalScore: 1450,
        gratitudeScore: 400,
        emotionLogScore: 0,
        activitiesCompleted: 82,
        streakDays: 12,
        rank: 4,
      ),
      const LeaderboardUser(
        userId: 'user5',
        username: 'MindfulJourney',
        totalScore: 8420,
        gameScore: 2800,
        meditationScore: 3900,
        journalScore: 1320,
        gratitudeScore: 400,
        emotionLogScore: 0,
        activitiesCompleted: 71,
        streakDays: 9,
        rank: 5,
      ),
      const LeaderboardUser(
        userId: 'user6',
        username: 'InnerPeace',
        totalScore: 7650,
        gameScore: 2400,
        meditationScore: 3600,
        journalScore: 1250,
        gratitudeScore: 400,
        emotionLogScore: 0,
        activitiesCompleted: 64,
        streakDays: 7,
        rank: 6,
      ),
      const LeaderboardUser(
        userId: 'user7',
        username: 'WellnessPath',
        totalScore: 6890,
        gameScore: 2100,
        meditationScore: 3200,
        journalScore: 1190,
        gratitudeScore: 400,
        emotionLogScore: 0,
        activitiesCompleted: 58,
        streakDays: 5,
        rank: 7,
      ),
      const LeaderboardUser(
        userId: 'user8',
        username: 'CalmMind',
        totalScore: 6240,
        gameScore: 1900,
        meditationScore: 2900,
        journalScore: 1040,
        gratitudeScore: 400,
        emotionLogScore: 0,
        activitiesCompleted: 52,
        streakDays: 4,
        rank: 8,
      ),
      const LeaderboardUser(
        userId: 'user9',
        username: 'BalancedLife',
        totalScore: 5680,
        gameScore: 1700,
        meditationScore: 2600,
        journalScore: 980,
        gratitudeScore: 400,
        emotionLogScore: 0,
        activitiesCompleted: 47,
        streakDays: 3,
        rank: 9,
      ),
      const LeaderboardUser(
        userId: 'user10',
        username: 'PeacefulSoul',
        totalScore: 5120,
        gameScore: 1500,
        meditationScore: 2300,
        journalScore: 920,
        gratitudeScore: 400,
        emotionLogScore: 0,
        activitiesCompleted: 42,
        streakDays: 2,
        rank: 10,
      ),
    ];

    // Current user (rank 15 for example)
    _currentUserRank = const LeaderboardUser(
      userId: 'current_user',
      username: 'You',
      totalScore: 2850,
      gameScore: 950,
      meditationScore: 1200,
      journalScore: 500,
      gratitudeScore: 200,
      emotionLogScore: 0,
      activitiesCompleted: 28,
      streakDays: 3,
      rank: 15,
    );

    notifyListeners();
  }

  /// Refresh leaderboard data
  Future<void> refreshLeaderboard() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would fetch from Firestore
    _initializeLeaderboard();

    _isLoading = false;
    notifyListeners();
  }

  /// Update user score (called when user completes activities)
  void updateUserScore(int additionalScore, ActivityType activityType) {
    if (_currentUserRank == null) return;

    // Create updated score
    final updatedScore = _currentUserRank!.totalScore + additionalScore;
    
    // Update the current user rank (simplified - in real app would recalculate rank)
    _currentUserRank = LeaderboardUser(
      userId: _currentUserRank!.userId,
      username: _currentUserRank!.username,
      totalScore: updatedScore,
      gameScore: activityType == ActivityType.game 
          ? _currentUserRank!.gameScore + additionalScore 
          : _currentUserRank!.gameScore,
      meditationScore: activityType == ActivityType.meditation 
          ? _currentUserRank!.meditationScore + additionalScore 
          : _currentUserRank!.meditationScore,
      journalScore: activityType == ActivityType.journal 
          ? _currentUserRank!.journalScore + additionalScore 
          : _currentUserRank!.journalScore,
      gratitudeScore: activityType == ActivityType.gratitude 
          ? _currentUserRank!.gratitudeScore + additionalScore 
          : _currentUserRank!.gratitudeScore,
      emotionLogScore: activityType == ActivityType.emotionLog 
          ? _currentUserRank!.emotionLogScore + additionalScore 
          : _currentUserRank!.emotionLogScore,
      activitiesCompleted: _currentUserRank!.activitiesCompleted + 1,
      streakDays: _currentUserRank!.streakDays,
      rank: _currentUserRank!.rank, // Would be recalculated in real app
    );

    notifyListeners();
  }
}