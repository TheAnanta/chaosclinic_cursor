import 'dart:math';
import 'package:flutter/material.dart';

/// Bug model for the Bug Smash game
class Bug {
  final String id;
  final Offset position;
  final double speed;
  final BugType type;
  final Color color;
  bool isSmashed;
  
  Bug({
    required this.id,
    required this.position,
    required this.speed,
    required this.type,
    required this.color,
    this.isSmashed = false,
  });
  
  Bug copyWith({
    Offset? position,
    bool? isSmashed,
  }) {
    return Bug(
      id: id,
      position: position ?? this.position,
      speed: speed,
      type: type,
      color: color,
      isSmashed: isSmashed ?? this.isSmashed,
    );
  }
}

enum BugType {
  stress,    // Red bugs - cause stress
  anxiety,   // Orange bugs - cause anxiety 
  worry,     // Yellow bugs - cause worry
  calm,      // Blue bugs - give calm points
  joy,       // Green bugs - give joy points
}

/// Bug generator and game logic
class BugSmashGame {
  static final Random _random = Random();
  
  static Bug generateRandomBug(Size screenSize) {
    final bugTypes = BugType.values;
    final type = bugTypes[_random.nextInt(bugTypes.length)];
    
    return Bug(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      position: Offset(
        _random.nextDouble() * (screenSize.width - 60), // 60 is bug size
        _random.nextDouble() * (screenSize.height - 200), // Account for UI
      ),
      speed: _random.nextDouble() * 2 + 1, // Speed between 1-3
      type: type,
      color: _getBugColor(type),
    );
  }
  
  static Color _getBugColor(BugType type) {
    switch (type) {
      case BugType.stress:
        return Colors.red.shade600;
      case BugType.anxiety:
        return Colors.orange.shade600;
      case BugType.worry:
        return Colors.yellow.shade700;
      case BugType.calm:
        return Colors.blue.shade600;
      case BugType.joy:
        return Colors.green.shade600;
    }
  }
  
  static int getPointsForBug(BugType type) {
    switch (type) {
      case BugType.stress:
        return 10; // High points for removing stress
      case BugType.anxiety:
        return 8;
      case BugType.worry:
        return 6;
      case BugType.calm:
        return 15; // Bonus for catching positive emotions
      case BugType.joy:
        return 20; // Highest bonus for joy
    }
  }
  
  static String getBugEmoji(BugType type) {
    switch (type) {
      case BugType.stress:
        return '😰';
      case BugType.anxiety:
        return '😟';
      case BugType.worry:
        return '😕';
      case BugType.calm:
        return '😌';
      case BugType.joy:
        return '😊';
    }
  }
  
  static String getBugDescription(BugType type) {
    switch (type) {
      case BugType.stress:
        return 'Stress Bug - Smash to reduce stress!';
      case BugType.anxiety:
        return 'Anxiety Bug - Catch to ease anxiety!';
      case BugType.worry:
        return 'Worry Bug - Squash those worries!';
      case BugType.calm:
        return 'Calm Bug - Collect for peace!';
      case BugType.joy:
        return 'Joy Bug - Gather happiness!';
    }
  }
}