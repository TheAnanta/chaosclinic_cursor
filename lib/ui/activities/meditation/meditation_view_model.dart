import 'dart:async';
import 'package:flutter/material.dart';

enum MeditationState {
  initial,
  preparation,
  inProgress,
  paused,
  completed,
}

enum MeditationType {
  breathing,
  bodyScroll,
  mindfulness,
  loving_kindness,
}

/// Meditation session model
class MeditationSession {
  final String id;
  final String title;
  final String description;
  final MeditationType type;
  final Duration duration;
  final List<MeditationStep> steps;
  final String backgroundMusic;
  
  MeditationSession({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.duration,
    required this.steps,
    required this.backgroundMusic,
  });
}

class MeditationStep {
  final String instruction;
  final Duration duration;
  final String? audioGuidance;
  
  MeditationStep({
    required this.instruction,
    required this.duration,
    this.audioGuidance,
  });
}

/// View model for guided meditation
class MeditationViewModel extends ChangeNotifier {
  MeditationState _state = MeditationState.initial;
  MeditationSession? _currentSession;
  
  // Progress tracking
  int _currentStepIndex = 0;
  Duration _stepTimeRemaining = Duration.zero;
  Duration _totalTimeRemaining = Duration.zero;
  Timer? _timer;
  
  // Breathing guide
  bool _breathingIn = true;
  Timer? _breathingTimer;
  
  // Getters
  MeditationState get state => _state;
  MeditationSession? get currentSession => _currentSession;
  int get currentStepIndex => _currentStepIndex;
  Duration get stepTimeRemaining => _stepTimeRemaining;
  Duration get totalTimeRemaining => _totalTimeRemaining;
  bool get breathingIn => _breathingIn;
  
  MeditationStep? get currentStep => 
      _currentSession != null && _currentStepIndex < _currentSession!.steps.length
          ? _currentSession!.steps[_currentStepIndex]
          : null;
  
  double get progressPercentage {
    if (_currentSession == null) return 0.0;
    final totalDuration = _currentSession!.duration.inSeconds;
    final remaining = _totalTimeRemaining.inSeconds;
    return (totalDuration - remaining) / totalDuration;
  }
  
  /// Start a meditation session
  void startSession(MeditationSession session) {
    _currentSession = session;
    _currentStepIndex = 0;
    _totalTimeRemaining = session.duration;
    _stepTimeRemaining = session.steps.isNotEmpty 
        ? session.steps[0].duration 
        : Duration.zero;
    _state = MeditationState.preparation;
    notifyListeners();
  }
  
  /// Begin the meditation
  void beginMeditation() {
    if (_currentSession == null) return;
    
    _state = MeditationState.inProgress;
    _startTimer();
    
    // Start breathing guide for breathing meditations
    if (_currentSession!.type == MeditationType.breathing) {
      _startBreathingGuide();
    }
    
    notifyListeners();
  }
  
  /// Pause the meditation
  void pauseMeditation() {
    if (_state == MeditationState.inProgress) {
      _state = MeditationState.paused;
      _timer?.cancel();
      _breathingTimer?.cancel();
      notifyListeners();
    }
  }
  
  /// Resume the meditation
  void resumeMeditation() {
    if (_state == MeditationState.paused) {
      _state = MeditationState.inProgress;
      _startTimer();
      
      if (_currentSession!.type == MeditationType.breathing) {
        _startBreathingGuide();
      }
      
      notifyListeners();
    }
  }
  
  /// End the meditation
  void endMeditation() {
    _state = MeditationState.completed;
    _timer?.cancel();
    _breathingTimer?.cancel();
    notifyListeners();
  }
  
  /// Skip to next step
  void nextStep() {
    if (_currentSession == null || _currentStepIndex >= _currentSession!.steps.length - 1) {
      endMeditation();
      return;
    }
    
    _currentStepIndex++;
    _stepTimeRemaining = _currentSession!.steps[_currentStepIndex].duration;
    notifyListeners();
  }
  
  /// Start the main timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _stepTimeRemaining = Duration(seconds: _stepTimeRemaining.inSeconds - 1);
      _totalTimeRemaining = Duration(seconds: _totalTimeRemaining.inSeconds - 1);
      
      if (_stepTimeRemaining.inSeconds <= 0) {
        nextStep();
      } else if (_totalTimeRemaining.inSeconds <= 0) {
        endMeditation();
      } else {
        notifyListeners();
      }
    });
  }
  
  /// Start breathing guide animation
  void _startBreathingGuide() {
    _breathingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _breathingIn = !_breathingIn;
      notifyListeners();
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _breathingTimer?.cancel();
    super.dispose();
  }
}

/// Meditation session presets
class MeditationPresets {
  static List<MeditationSession> getDefaultSessions() {
    return [
      MeditationSession(
        id: '1',
        title: '5-Minute Breathing',
        description: 'A quick breathing exercise to center yourself',
        type: MeditationType.breathing,
        duration: const Duration(minutes: 5),
        backgroundMusic: 'calm_ocean',
        steps: [
          MeditationStep(
            instruction: 'Find a comfortable position and close your eyes',
            duration: const Duration(seconds: 30),
          ),
          MeditationStep(
            instruction: 'Take slow, deep breaths. Breathe in for 4 counts, hold for 4, out for 4',
            duration: const Duration(minutes: 4),
          ),
          MeditationStep(
            instruction: 'Slowly open your eyes and return to your day',
            duration: const Duration(seconds: 30),
          ),
        ],
      ),
      MeditationSession(
        id: '2',
        title: '10-Minute Mindfulness',
        description: 'Practice present moment awareness',
        type: MeditationType.mindfulness,
        duration: const Duration(minutes: 10),
        backgroundMusic: 'forest_sounds',
        steps: [
          MeditationStep(
            instruction: 'Sit comfortably and close your eyes',
            duration: const Duration(minutes: 1),
          ),
          MeditationStep(
            instruction: 'Notice your breath without changing it',
            duration: const Duration(minutes: 3),
          ),
          MeditationStep(
            instruction: 'When your mind wanders, gently return to your breath',
            duration: const Duration(minutes: 5),
          ),
          MeditationStep(
            instruction: 'Slowly wiggle your fingers and toes, then open your eyes',
            duration: const Duration(minutes: 1),
          ),
        ],
      ),
      MeditationSession(
        id: '3',
        title: 'Body Scan Relaxation',
        description: 'Release tension throughout your body',
        type: MeditationType.bodyScroll,
        duration: const Duration(minutes: 15),
        backgroundMusic: 'rain_sounds',
        steps: [
          MeditationStep(
            instruction: 'Lie down comfortably and close your eyes',
            duration: const Duration(minutes: 1),
          ),
          MeditationStep(
            instruction: 'Focus on your toes. Notice any tension and let it go',
            duration: const Duration(minutes: 2),
          ),
          MeditationStep(
            instruction: 'Move your attention up to your feet and ankles',
            duration: const Duration(minutes: 2),
          ),
          MeditationStep(
            instruction: 'Continue scanning up through your legs',
            duration: const Duration(minutes: 3),
          ),
          MeditationStep(
            instruction: 'Focus on your torso and arms',
            duration: const Duration(minutes: 3),
          ),
          MeditationStep(
            instruction: 'Relax your neck, face, and head',
            duration: const Duration(minutes: 3),
          ),
          MeditationStep(
            instruction: 'Take a moment to feel your whole body relaxed',
            duration: const Duration(minutes: 1),
          ),
        ],
      ),
      MeditationSession(
        id: '4',
        title: 'Loving-Kindness',
        description: 'Cultivate compassion for yourself and others',
        type: MeditationType.loving_kindness,
        duration: const Duration(minutes: 12),
        backgroundMusic: 'gentle_bells',
        steps: [
          MeditationStep(
            instruction: 'Sit comfortably and bring to mind a feeling of warmth',
            duration: const Duration(minutes: 1),
          ),
          MeditationStep(
            instruction: 'Send loving-kindness to yourself: "May I be happy, may I be peaceful"',
            duration: const Duration(minutes: 3),
          ),
          MeditationStep(
            instruction: 'Think of someone you love and send them loving-kindness',
            duration: const Duration(minutes: 3),
          ),
          MeditationStep(
            instruction: 'Think of someone neutral and send them loving-kindness',
            duration: const Duration(minutes: 2),
          ),
          MeditationStep(
            instruction: 'Think of someone difficult and send them loving-kindness',
            duration: const Duration(minutes: 2),
          ),
          MeditationStep(
            instruction: 'Extend loving-kindness to all beings everywhere',
            duration: const Duration(minutes: 1),
          ),
        ],
      ),
    ];
  }
}