import 'package:flutter/material.dart';

/// Journal entry model
class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final JournalMood? mood;
  final List<String> gratitudeItems;
  
  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.mood,
    this.gratitudeItems = const [],
  });
  
  JournalEntry copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    List<String>? tags,
    JournalMood? mood,
    List<String>? gratitudeItems,
  }) {
    return JournalEntry(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      gratitudeItems: gratitudeItems ?? this.gratitudeItems,
    );
  }
}

class JournalMood {
  final String emotion;
  final int intensity; // 1-5
  final Color color;
  
  JournalMood({
    required this.emotion,
    required this.intensity,
    required this.color,
  });
}

/// Journal prompts for guided writing
class JournalPrompts {
  static List<String> getGratitudePrompts() {
    return [
      "What are three things you're grateful for today?",
      "Who in your life are you most thankful for and why?",
      "What small moment brought you joy today?",
      "What challenge are you grateful to have overcome?",
      "What skills or abilities are you thankful to have?",
    ];
  }
  
  static List<String> getReflectionPrompts() {
    return [
      "How are you feeling right now, and why?",
      "What's one thing that went well today?",
      "What did you learn about yourself today?",
      "What would you like to tell your future self?",
      "What's one thing you're looking forward to?",
      "If today had a theme, what would it be?",
      "What brought you comfort today?",
      "What challenged you today, and how did you handle it?",
    ];
  }
  
  static List<String> getCreativePrompts() {
    return [
      "Describe your perfect day from start to finish",
      "Write a letter to someone who has impacted your life",
      "If you could have dinner with anyone, who would it be and why?",
      "What advice would you give to your younger self?",
      "Describe a place where you feel completely at peace",
      "What's a dream you'd like to pursue?",
    ];
  }
  
  static List<String> getMindfulnessPrompts() {
    return [
      "What do you notice about your body right now?",
      "What sounds, smells, or sensations are you aware of?",
      "What thoughts are flowing through your mind?",
      "How has your breathing changed since you started writing?",
      "What emotions are present for you right now?",
    ];
  }
}

/// View model for journaling
class JournalViewModel extends ChangeNotifier {
  List<JournalEntry> _entries = [];
  JournalEntry? _currentEntry;
  bool _isEditing = false;
  String _selectedPromptCategory = 'Reflection';
  
  // Form state
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final List<TextEditingController> gratitudeControllers = 
      List.generate(3, (_) => TextEditingController());
  
  JournalMood? _selectedMood;
  List<String> _selectedTags = [];
  
  // Getters
  List<JournalEntry> get entries => _entries;
  JournalEntry? get currentEntry => _currentEntry;
  bool get isEditing => _isEditing;
  String get selectedPromptCategory => _selectedPromptCategory;
  JournalMood? get selectedMood => _selectedMood;
  List<String> get selectedTags => _selectedTags;
  
  List<String> get currentPrompts {
    switch (_selectedPromptCategory) {
      case 'Gratitude':
        return JournalPrompts.getGratitudePrompts();
      case 'Reflection':
        return JournalPrompts.getReflectionPrompts();
      case 'Creative':
        return JournalPrompts.getCreativePrompts();
      case 'Mindfulness':
        return JournalPrompts.getMindfulnessPrompts();
      default:
        return JournalPrompts.getReflectionPrompts();
    }
  }
  
  /// Start a new journal entry
  void startNewEntry() {
    _currentEntry = null;
    _isEditing = true;
    _clearForm();
    _generateTitle();
    notifyListeners();
  }
  
  /// Start editing an existing entry
  void editEntry(JournalEntry entry) {
    _currentEntry = entry;
    _isEditing = true;
    _loadEntryIntoForm(entry);
    notifyListeners();
  }
  
  /// Save the current entry
  void saveEntry() {
    if (contentController.text.trim().isEmpty) return;
    
    final now = DateTime.now();
    
    if (_currentEntry == null) {
      // Create new entry
      final entry = JournalEntry(
        id: now.millisecondsSinceEpoch.toString(),
        title: titleController.text.trim().isEmpty 
            ? _generateDefaultTitle() 
            : titleController.text.trim(),
        content: contentController.text.trim(),
        createdAt: now,
        mood: _selectedMood,
        tags: List.from(_selectedTags),
        gratitudeItems: gratitudeControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
      );
      _entries.insert(0, entry);
    } else {
      // Update existing entry
      final updatedEntry = _currentEntry!.copyWith(
        title: titleController.text.trim().isEmpty 
            ? _currentEntry!.title 
            : titleController.text.trim(),
        content: contentController.text.trim(),
        updatedAt: now,
        mood: _selectedMood,
        tags: List.from(_selectedTags),
        gratitudeItems: gratitudeControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
      );
      
      final index = _entries.indexWhere((e) => e.id == _currentEntry!.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
      }
    }
    
    _isEditing = false;
    _currentEntry = null;
    _clearForm();
    notifyListeners();
  }
  
  /// Cancel editing
  void cancelEditing() {
    _isEditing = false;
    _currentEntry = null;
    _clearForm();
    notifyListeners();
  }
  
  /// Delete an entry
  void deleteEntry(String entryId) {
    _entries.removeWhere((entry) => entry.id == entryId);
    if (_currentEntry?.id == entryId) {
      _currentEntry = null;
      _isEditing = false;
      _clearForm();
    }
    notifyListeners();
  }
  
  /// Set mood for current entry
  void setMood(JournalMood mood) {
    _selectedMood = mood;
    notifyListeners();
  }
  
  /// Toggle tag selection
  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }
  
  /// Set prompt category
  void setPromptCategory(String category) {
    _selectedPromptCategory = category;
    notifyListeners();
  }
  
  /// Apply a prompt to the content
  void applyPrompt(String prompt) {
    if (contentController.text.isEmpty) {
      contentController.text = '$prompt\n\n';
    } else {
      contentController.text += '\n\n$prompt\n\n';
    }
    notifyListeners();
  }
  
  /// Clear form
  void _clearForm() {
    titleController.clear();
    contentController.clear();
    for (final controller in gratitudeControllers) {
      controller.clear();
    }
    _selectedMood = null;
    _selectedTags.clear();
  }
  
  /// Load entry into form
  void _loadEntryIntoForm(JournalEntry entry) {
    titleController.text = entry.title;
    contentController.text = entry.content;
    _selectedMood = entry.mood;
    _selectedTags = List.from(entry.tags);
    
    for (int i = 0; i < gratitudeControllers.length; i++) {
      if (i < entry.gratitudeItems.length) {
        gratitudeControllers[i].text = entry.gratitudeItems[i];
      } else {
        gratitudeControllers[i].clear();
      }
    }
  }
  
  /// Generate default title based on date
  String _generateDefaultTitle() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
  
  /// Generate automatic title
  void _generateTitle() {
    titleController.text = _generateDefaultTitle();
  }
  
  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    for (final controller in gratitudeControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}