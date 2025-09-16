import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_search_game.dart';

enum WordSearchGameState {
  initial,
  wordInput, // New state for user word input
  playing,
  paused,
  completed,
  checkinDialog,
}

/// View model for Word Search game
class WordSearchViewModel extends ChangeNotifier {
  WordSearchGame? _game;
  WordSearchGameState _state = WordSearchGameState.initial;
  
  // Game timing - countdown instead of elapsed time
  Timer? _countdownTimer;
  Duration _timeRemaining = const Duration(seconds: 30); // 30 second countdown
  static const Duration _initialCountdown = Duration(seconds: 30);
  
  // Selection state
  List<GridPosition> _currentSelection = [];
  List<GridPosition> _selectedPositions = [];
  Set<GridPosition> _foundPositions = {};
  Set<GridPosition> _highlightedPositions = {}; // For highlighting during selection
  
  // Score and progress
  int _score = 0;
  int _hintsUsed = 0;
  int _wrongSelections = 0;
  
  // Inactivity detection
  Timer? _inactivityTimer;
  DateTime _lastActivity = DateTime.now();
  bool _hasShown10sPopup = false;
  bool _hasShown20sPopup = false;
  
  // Current word being formed during selection
  String _currentWord = '';
  bool _isValidatingWord = false;
  
  // User word input
  final List<String> _userWords = [];
  final TextEditingController wordInputController = TextEditingController();

  // Getters
  WordSearchGame? get game => _game;
  WordSearchGameState get state => _state;
  Duration get timeRemaining => _timeRemaining;
  List<GridPosition> get currentSelection => _currentSelection;
  Set<GridPosition> get foundPositions => _foundPositions;
  Set<GridPosition> get highlightedPositions => _highlightedPositions;
  int get score => _score;
  int get hintsUsed => _hintsUsed;
  int get wrongSelections => _wrongSelections;
  bool get isGameCompleted => _game?.words.every((word) => word.isFound) ?? false;
  int get wordsFound => _game?.words.where((word) => word.isFound).length ?? 0;
  int get totalWords => _game?.words.length ?? 0;
  String get currentWord => _currentWord;
  bool get isValidatingWord => _isValidatingWord;
  List<String> get userWords => _userWords;

  /// Show word input dialog for user to choose words
  void showWordInput() {
    _state = WordSearchGameState.wordInput;
    notifyListeners();
  }

  /// Add a user word
  void addUserWord(String word) {
    if (word.trim().isNotEmpty && word.trim().length >= 3) {
      _userWords.add(word.trim().toUpperCase());
      wordInputController.clear();
      notifyListeners();
    }
  }

  /// Remove a user word
  void removeUserWord(String word) {
    _userWords.remove(word);
    notifyListeners();
  }

  /// Start a new game with user-chosen words or defaults
  void startNewGame({List<String>? customWords}) {
    final wordsToUse = _userWords.isNotEmpty ? _userWords : customWords;
    _game = WordSearchGenerator.generate(customWords: wordsToUse);
    _state = WordSearchGameState.playing;
    _resetGameState();
    _startCountdown();
    _startInactivityTimer();
    notifyListeners();
  }

  /// Pause the game
  void pauseGame() {
    if (_state == WordSearchGameState.playing) {
      _state = WordSearchGameState.paused;
      _countdownTimer?.cancel();
      _inactivityTimer?.cancel();
      notifyListeners();
    }
  }

  /// Resume the game
  void resumeGame() {
    if (_state == WordSearchGameState.paused) {
      _state = WordSearchGameState.playing;
      _startCountdown();
      _startInactivityTimer();
      notifyListeners();
    }
  }

  /// Start cell selection
  void startSelection(GridPosition position) {
    if (_state != WordSearchGameState.playing) return;
    
    _recordActivity();
    _currentSelection = [position];
    _highlightedPositions = {position};
    _currentWord = _game!.grid[position.row][position.col];
    notifyListeners();
  }

  /// Update selection (drag)
  void updateSelection(GridPosition position) {
    if (_state != WordSearchGameState.playing || _currentSelection.isEmpty) return;
    
    _recordActivity();
    final startPos = _currentSelection.first;
    _currentSelection = _getPathBetween(startPos, position);
    _highlightedPositions = _currentSelection.toSet();
    _currentWord = _currentSelection.map((pos) => _game!.grid[pos.row][pos.col]).join();
    notifyListeners();
  }

  /// End selection and validate word
  void endSelection() async {
    if (_state != WordSearchGameState.playing || _currentSelection.isEmpty) return;
    
    _recordActivity();
    
    // Check if word is in our predefined list first
    final foundWord = _checkWordFound();
    if (foundWord != null) {
      _markWordAsFound(foundWord);
      _score += _calculateScore(foundWord);
      
      if (isGameCompleted) {
        _completeGame();
      }
    } else if (_currentWord.length >= 3) {
      // Check if it's a valid English word
      _isValidatingWord = true;
      notifyListeners();
      
      final isValid = await _game!.isValidEnglishWord(_currentWord);
      _isValidatingWord = false;
      
      if (isValid) {
        // Valid English word but not in our list - give partial points
        _score += _currentWord.length * 2;
        _foundPositions.addAll(_currentSelection);
      } else {
        _wrongSelections++;
      }
    } else {
      _wrongSelections++;
    }
    
    _currentSelection = [];
    _highlightedPositions = {};
    _currentWord = '';
    notifyListeners();
  }
    
    final foundWord = _checkWordFound();
    if (foundWord != null) {
      _markWordAsFound(foundWord);
      _score += _calculateScore(foundWord);
      
      if (isGameCompleted) {
        _completeGame();
      }
    } else {
      _wrongSelections++;
      _checkForProactiveCheckIn();
    }
    
    _currentSelection = [];
    notifyListeners();
  }

  /// Use a hint
  void useHint() {
    if (_state != WordSearchGameState.playing || _game == null) return;
    
    final unFoundWords = _game!.words.where((word) => !word.isFound).toList();
    if (unFoundWords.isNotEmpty) {
      final wordToHint = unFoundWords.first;
      final firstPosition = wordToHint.positions.first;
      
      // Highlight the first letter for 2 seconds
      _foundPositions.add(firstPosition);
      _hintsUsed++;
      notifyListeners();
      
      Timer(const Duration(seconds: 2), () {
        _foundPositions.remove(firstPosition);
        notifyListeners();
      });
    }
  }

  /// Handle check-in dialog response
  void handleCheckInResponse(bool needsSupport) {
    _state = WordSearchGameState.playing;
    _hasShownCheckIn = true;
    
    if (needsSupport) {
      // This would typically trigger navigation to support resources
      // For now, we'll just resume the game
    }
    
    _startCheckInTimer();
    notifyListeners();
  }

  /// Dismiss check-in dialog
  void dismissCheckIn() {
    _state = WordSearchGameState.playing;
    _hasShownCheckIn = true;
    _startCheckInTimer();
    notifyListeners();
  }

  /// Reset game state
  void _resetGameState() {
    _timeRemaining = _initialCountdown;
    _currentSelection = [];
    _selectedPositions = [];
    _foundPositions = {};
    _highlightedPositions = {};
    _score = 0;
    _hintsUsed = 0;
    _wrongSelections = 0;
    _hasShown10sPopup = false;
    _hasShown20sPopup = false;
    _currentWord = '';
    _isValidatingWord = false;
    _lastActivity = DateTime.now();
    _countdownTimer?.cancel();
    _inactivityTimer?.cancel();
  }

  /// Start countdown timer (30 seconds)
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining.inSeconds > 0) {
        _timeRemaining = Duration(seconds: _timeRemaining.inSeconds - 1);
        notifyListeners();
      } else {
        _endGameTimeout();
      }
    });
  }

  /// Start inactivity detection timer
  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final inactiveFor = now.difference(_lastActivity);
      
      if (inactiveFor.inSeconds >= 10 && !_hasShown10sPopup) {
        _hasShown10sPopup = true;
        _showInactivityPopup("Take your time! You're doing great.");
      } else if (inactiveFor.inSeconds >= 20 && !_hasShown20sPopup) {
        _hasShown20sPopup = true;
        _showInactivityPopup("Need a hint? Or just enjoying the puzzle?");
      }
    });
  }

  /// Record user activity
  void _recordActivity() {
    _lastActivity = DateTime.now();
  }

  /// Show inactivity popup
  void _showInactivityPopup(String message) {
    // This would show a brief overlay message
    // For now, we'll just increment score as encouragement
    _score += 5;
    notifyListeners();
  }

  /// End game due to timeout
  void _endGameTimeout() {
    _state = WordSearchGameState.completed;
    _countdownTimer?.cancel();
    _inactivityTimer?.cancel();
    notifyListeners();
  }

  /// Get path between two positions (for line selection)
  List<GridPosition> _getPathBetween(GridPosition start, GridPosition end) {
    final path = <GridPosition>[start];
    
    final rowDiff = end.row - start.row;
    final colDiff = end.col - start.col;
    
    // Only allow straight lines (horizontal, vertical, diagonal)
    if (rowDiff != 0 && colDiff != 0 && rowDiff.abs() != colDiff.abs()) {
      return [start]; // Invalid selection
    }
    
    final rowStep = rowDiff == 0 ? 0 : (rowDiff > 0 ? 1 : -1);
    final colStep = colDiff == 0 ? 0 : (colDiff > 0 ? 1 : -1);
    
    var currentRow = start.row + rowStep;
    var currentCol = start.col + colStep;
    
    while (currentRow != end.row + rowStep || currentCol != end.col + colStep) {
      if (currentRow < 0 || currentRow >= (_game?.size ?? 0) ||
          currentCol < 0 || currentCol >= (_game?.size ?? 0)) {
        break;
      }
      
      path.add(GridPosition(currentRow, currentCol));
      
      if (currentRow == end.row && currentCol == end.col) break;
      
      currentRow += rowStep;
      currentCol += colStep;
    }
    
    return path;
  }

  /// Check if current selection forms a valid word
  WordSearchWord? _checkWordFound() {
    if (_game == null || _currentSelection.length < 2) return null;
    
    try {
      return _game!.getFoundWord(_currentSelection);
    } catch (e) {
      return null;
    }
  }

  /// Mark word as found
  void _markWordAsFound(WordSearchWord word) {
    word.isFound = true;
    _foundPositions.addAll(word.positions);
  }

  /// Calculate score for found word
  int _calculateScore(WordSearchWord word) {
    var baseScore = word.text.length * 10;
    
    // Bonus for time remaining (more time left = more bonus)
    final timeBonus = _timeRemaining.inSeconds;
    
    // Penalty for hints
    final hintPenalty = _hintsUsed * 5;
    
    return math.max(5, baseScore + timeBonus - hintPenalty);
  }

  /// Complete the game
  void _completeGame() {
    _state = WordSearchGameState.completed;
    _countdownTimer?.cancel();
    _inactivityTimer?.cancel();
    
    // Add completion bonus
    _score += 50 + _timeRemaining.inSeconds; // Bonus for time remaining
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _inactivityTimer?.cancel();
    wordInputController.dispose();
    super.dispose();
  }
}