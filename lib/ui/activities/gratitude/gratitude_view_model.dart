import 'package:flutter/material.dart';

/// Gratitude entry model
class GratitudeEntry {
  final String id;
  final List<String> gratitudeItems;
  final DateTime createdAt;
  final String? prompt;
  
  GratitudeEntry({
    required this.id,
    required this.gratitudeItems,
    required this.createdAt,
    this.prompt,
  });
}

/// View model for gratitude practice
class GratitudeViewModel extends ChangeNotifier {
  List<GratitudeEntry> _gratitudeEntries = [];
  bool _isWriting = false;
  String? _currentPrompt;
  
  // Form controllers
  final List<TextEditingController> gratitudeControllers = 
      List.generate(5, (_) => TextEditingController());
  
  // Getters
  List<GratitudeEntry> get gratitudeEntries => _gratitudeEntries;
  bool get isWriting => _isWriting;
  String? get currentPrompt => _currentPrompt;
  
  // Gratitude prompts
  List<String> get gratitudePrompts => [
    "What are three things you're grateful for today?",
    "Who in your life are you most thankful for and why?",
    "What small moment brought you joy today?",
    "What challenge are you grateful to have overcome?",
    "What skills or abilities are you thankful to have?",
    "What aspect of your health are you grateful for?",
    "What opportunity are you grateful for right now?",
    "What made you smile recently?",
  ];
  
  /// Start new gratitude practice
  void startNewGratitudePractice() {
    _isWriting = true;
    _currentPrompt = null;
    _clearControllers();
    notifyListeners();
  }
  
  /// Start with a specific prompt
  void startWithPrompt(String prompt) {
    _isWriting = true;
    _currentPrompt = prompt;
    _clearControllers();
    notifyListeners();
  }
  
  /// Save gratitude practice
  void saveGratitudePractice() {
    final gratitudeItems = gratitudeControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    
    if (gratitudeItems.isEmpty) {
      return; // Don't save empty entries
    }
    
    final entry = GratitudeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gratitudeItems: gratitudeItems,
      createdAt: DateTime.now(),
      prompt: _currentPrompt,
    );
    
    _gratitudeEntries.insert(0, entry);
    _isWriting = false;
    _currentPrompt = null;
    _clearControllers();
    notifyListeners();
  }
  
  /// Cancel writing
  void cancelWriting() {
    _isWriting = false;
    _currentPrompt = null;
    _clearControllers();
    notifyListeners();
  }
  
  /// Clear all controllers
  void _clearControllers() {
    for (final controller in gratitudeControllers) {
      controller.clear();
    }
  }
  
  @override
  void dispose() {
    for (final controller in gratitudeControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}