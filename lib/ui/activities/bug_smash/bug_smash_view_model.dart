import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'bug_smash_game.dart';

enum BugSmashGameState {
  initial,
  playing,
  paused,
  gameOver,
  checkinDialog,
}

/// View model for Bug Smash game
class BugSmashViewModel extends ChangeNotifier {
  BugSmashGameState _state = BugSmashGameState.initial;
  
  // Game state
  List<Bug> _bugs = [];
  int _score = 0;
  int _lives = 3;
  Duration _timeRemaining = const Duration(minutes: 2);
  Timer? _gameTimer;
  Timer? _bugSpawnTimer;
  Timer? _bugMoveTimer;
  Size _screenSize = const Size(400, 600);
  
  // Proactive check-in
  Timer? _checkInTimer;
  bool _hasShownCheckIn = false;
  int _missedPositiveBugs = 0;
  static const int _missedPositiveThreshold = 3;
  
  // Getters
  BugSmashGameState get state => _state;
  List<Bug> get bugs => _bugs;
  int get score => _score;
  int get lives => _lives;
  Duration get timeRemaining => _timeRemaining;
  bool get isGameActive => _state == BugSmashGameState.playing;
  
  /// Start a new game
  void startGame(Size screenSize) {
    _screenSize = screenSize;
    _state = BugSmashGameState.playing;
    _resetGameState();
    _startTimers();
    notifyListeners();
  }
  
  /// Pause the game
  void pauseGame() {
    if (_state == BugSmashGameState.playing) {
      _state = BugSmashGameState.paused;
      _pauseTimers();
      notifyListeners();
    }
  }
  
  /// Resume the game
  void resumeGame() {
    if (_state == BugSmashGameState.paused) {
      _state = BugSmashGameState.playing;
      _startTimers();
      notifyListeners();
    }
  }
  
  /// Smash a bug
  void smashBug(String bugId) {
    if (_state != BugSmashGameState.playing) return;
    
    final bugIndex = _bugs.indexWhere((bug) => bug.id == bugId);
    if (bugIndex != -1) {
      final bug = _bugs[bugIndex];
      
      if (!bug.isSmashed) {
        // Update bug as smashed
        _bugs[bugIndex] = bug.copyWith(isSmashed: true);
        
        // Add score
        _score += BugSmashGame.getPointsForBug(bug.type);
        
        // Check for positive bug collection
        if (bug.type == BugType.calm || bug.type == BugType.joy) {
          _missedPositiveBugs = 0; // Reset counter when positive bug is caught
        }
        
        // Remove bug after animation
        Timer(const Duration(milliseconds: 300), () {
          _bugs.removeWhere((b) => b.id == bugId);
          notifyListeners();
        });
        
        notifyListeners();
      }
    }
  }
  
  /// Handle check-in dialog response
  void handleCheckInResponse(bool needsSupport) {
    _state = BugSmashGameState.playing;
    _hasShownCheckIn = true;
    
    if (needsSupport) {
      // This would typically navigate to support resources
      pauseGame();
    } else {
      _startTimers();
    }
    
    notifyListeners();
  }
  
  /// Dismiss check-in dialog
  void dismissCheckIn() {
    _state = BugSmashGameState.playing;
    _hasShownCheckIn = true;
    _startTimers();
    notifyListeners();
  }
  
  /// Reset game state
  void _resetGameState() {
    _bugs = [];
    _score = 0;
    _lives = 3;
    _timeRemaining = const Duration(minutes: 2);
    _missedPositiveBugs = 0;
    _hasShownCheckIn = false;
    _pauseTimers();
  }
  
  /// Start all game timers
  void _startTimers() {
    _startGameTimer();
    _startBugSpawnTimer();
    _startBugMoveTimer();
    _startCheckInTimer();
  }
  
  /// Pause all timers
  void _pauseTimers() {
    _gameTimer?.cancel();
    _bugSpawnTimer?.cancel();
    _bugMoveTimer?.cancel();
    _checkInTimer?.cancel();
  }
  
  /// Start the main game timer
  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeRemaining = Duration(seconds: _timeRemaining.inSeconds - 1);
      
      if (_timeRemaining.inSeconds <= 0) {
        _endGame();
      }
      
      notifyListeners();
    });
  }
  
  /// Start bug spawning timer
  void _startBugSpawnTimer() {
    _bugSpawnTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_bugs.length < 8) { // Limit concurrent bugs
        _spawnBug();
      }
    });
  }
  
  /// Start bug movement timer
  void _startBugMoveTimer() {
    _bugMoveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _moveBugs();
    });
  }
  
  /// Start check-in timer
  void _startCheckInTimer() {
    if (!_hasShownCheckIn) {
      _checkInTimer = Timer(const Duration(seconds: 45), () {
        _showCheckInDialog();
      });
    }
  }
  
  /// Spawn a new bug
  void _spawnBug() {
    final bug = BugSmashGame.generateRandomBug(_screenSize);
    _bugs.add(bug);
    notifyListeners();
  }
  
  /// Move all bugs
  void _moveBugs() {
    final bugsToRemove = <Bug>[];
    
    for (int i = 0; i < _bugs.length; i++) {
      final bug = _bugs[i];
      if (bug.isSmashed) continue;
      
      // Move bug randomly
      final random = Random();
      final newX = (bug.position.dx + (random.nextDouble() - 0.5) * bug.speed * 20)
          .clamp(0.0, _screenSize.width - 60);
      final newY = (bug.position.dy + (random.nextDouble() - 0.5) * bug.speed * 20)
          .clamp(0.0, _screenSize.height - 200);
      
      _bugs[i] = bug.copyWith(position: Offset(newX, newY));
      
      // Check if bug should disappear (timeout)
      if (random.nextDouble() < 0.01) { // 1% chance per tick
        if (bug.type == BugType.calm || bug.type == BugType.joy) {
          _missedPositiveBugs++;
          _checkForProactiveCheckIn();
        } else {
          _lives--;
          if (_lives <= 0) {
            _endGame();
            return;
          }
        }
        bugsToRemove.add(bug);
      }
    }
    
    // Remove timed-out bugs
    for (final bug in bugsToRemove) {
      _bugs.remove(bug);
    }
    
    if (bugsToRemove.isNotEmpty) {
      notifyListeners();
    }
  }
  
  /// Check for proactive check-in triggers
  void _checkForProactiveCheckIn() {
    if (!_hasShownCheckIn && _missedPositiveBugs >= _missedPositiveThreshold) {
      _showCheckInDialog();
    }
  }
  
  /// Show proactive check-in dialog
  void _showCheckInDialog() {
    if (_state == BugSmashGameState.playing) {
      _state = BugSmashGameState.checkinDialog;
      _pauseTimers();
      notifyListeners();
    }
  }
  
  /// End the game
  void _endGame() {
    _state = BugSmashGameState.gameOver;
    _pauseTimers();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _pauseTimers();
    super.dispose();
  }
}