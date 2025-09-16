import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/themes/app_theme.dart';
import '../activities/meditation/meditation_view_model.dart';

/// Dedicated screen for breathing exercises
class BreathingExercisesScreen extends StatelessWidget {
  const BreathingExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MeditationViewModel(),
      child: const _BreathingExercisesContent(),
    );
  }
}

class _BreathingExercisesContent extends StatelessWidget {
  const _BreathingExercisesContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<MeditationViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Breathing Exercises'),
            elevation: 0,
            backgroundColor: AppTheme.calmColor,
            foregroundColor: Colors.white,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.calmColor,
                  AppTheme.calmColor.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppTheme.spacingXL),
                    Expanded(
                      child: _buildBreathingExercises(context, viewModel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.air,
            color: Colors.white,
            size: 48,
          ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            'Breathing Exercises',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacingS),
          Text(
            'Short breathing exercises to help you relax and center yourself',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingExercises(BuildContext context, MeditationViewModel viewModel) {
    final breathingExercises = _getBreathingExercises();
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
        childAspectRatio: 0.85,
      ),
      itemCount: breathingExercises.length,
      itemBuilder: (context, index) {
        final exercise = breathingExercises[index];
        return _buildExerciseCard(context, exercise, viewModel);
      },
    );
  }

  Widget _buildExerciseCard(BuildContext context, Map<String, dynamic> exercise, MeditationViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          onTap: () => _startExercise(context, exercise, viewModel),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: exercise['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                  child: Icon(
                    exercise['icon'],
                    color: exercise['color'],
                    size: 30,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  exercise['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  exercise['duration'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    exercise['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startExercise(BuildContext context, Map<String, dynamic> exercise, MeditationViewModel viewModel) {
    // For now, navigate to the main meditation screen with breathing type
    // In a full implementation, you would create specific sessions for each exercise
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ChangeNotifierProvider.value(
          value: viewModel,
          child: _BreathingExerciseSession(exercise: exercise),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getBreathingExercises() {
    return [
      {
        'title': '4-7-8 Breathing',
        'duration': '2 minutes',
        'description': 'Inhale for 4, hold for 7, exhale for 8. Great for relaxation.',
        'icon': Icons.schedule,
        'color': Colors.blue,
      },
      {
        'title': 'Box Breathing',
        'duration': '3 minutes',
        'description': 'Equal counts for inhale, hold, exhale, hold. Navy SEAL technique.',
        'icon': Icons.crop_square,
        'color': Colors.green,
      },
      {
        'title': 'Belly Breathing',
        'duration': '5 minutes',
        'description': 'Deep diaphragmatic breathing to reduce stress and anxiety.',
        'icon': Icons.favorite,
        'color': Colors.pink,
      },
      {
        'title': 'Coherent Breathing',
        'duration': '8 minutes',
        'description': 'Equal inhale and exhale for 5 seconds each. Balances the nervous system.',
        'icon': Icons.waves,
        'color': Colors.teal,
      },
    ];
  }
}

class _BreathingExerciseSession extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const _BreathingExerciseSession({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise['title']),
        backgroundColor: exercise['color'],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              exercise['color'],
              exercise['color'].withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3),
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    exercise['icon'],
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                Text(
                  exercise['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  exercise['description'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingXL),
                ElevatedButton(
                  onPressed: () {
                    // Start the breathing exercise
                    // This would integrate with the meditation system
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Starting ${exercise['title']}...'),
                        backgroundColor: exercise['color'],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: exercise['color'],
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXL,
                      vertical: AppTheme.spacingM,
                    ),
                  ),
                  child: const Text(
                    'Begin Exercise',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}