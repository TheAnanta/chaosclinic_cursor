import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import 'meditation_view_model.dart';

/// Guided Meditation screen
class MeditationScreen extends StatelessWidget {
  const MeditationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MeditationViewModel(),
      child: const _MeditationContent(),
    );
  }
}

class _MeditationContent extends StatelessWidget {
  const _MeditationContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<MeditationViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildAppBar(context, viewModel),
          body: _buildBody(context, viewModel),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MeditationViewModel viewModel) {
    return AppBar(
      title: const Text('Guided Meditation'),
      actions: [
        if (viewModel.state == MeditationState.inProgress) ...[
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: viewModel.pauseMeditation,
            tooltip: 'Pause',
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: viewModel.endMeditation,
            tooltip: 'End Session',
          ),
        ],
        if (viewModel.state == MeditationState.paused)
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: viewModel.resumeMeditation,
            tooltip: 'Resume',
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, MeditationViewModel viewModel) {
    switch (viewModel.state) {
      case MeditationState.initial:
        return _buildSessionSelector(context, viewModel);
      case MeditationState.preparation:
        return _buildPreparation(context, viewModel);
      case MeditationState.inProgress:
      case MeditationState.paused:
        return _buildMeditationSession(context, viewModel);
      case MeditationState.completed:
        return _buildCompletion(context, viewModel);
    }
  }

  Widget _buildSessionSelector(BuildContext context, MeditationViewModel viewModel) {
    final sessions = MeditationPresets.getDefaultSessions();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Meditation',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Take a moment to center yourself with guided meditation',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          ...sessions.map((session) => _buildSessionCard(context, session, viewModel)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, MeditationSession session, MeditationViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Material(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          onTap: () => viewModel.startSession(session),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getTypeColor(session.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Icon(
                    _getTypeIcon(session.type),
                    color: _getTypeColor(session.type),
                    size: 30,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        session.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        '${session.duration.inMinutes} minutes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getTypeColor(session.type),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreparation(BuildContext context, MeditationViewModel viewModel) {
    final session = viewModel.currentSession!;
    
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _getTypeColor(session.type).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(session.type),
              color: _getTypeColor(session.type),
              size: 60,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Text(
            session.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            session.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            '${session.duration.inMinutes} minutes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _getTypeColor(session.type),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(height: AppTheme.spacingM),
                const Text(
                  'Preparation Tips',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                const Text(
                  '• Find a quiet, comfortable space\n'
                  '• Sit or lie down comfortably\n'
                  '• Turn off notifications\n'
                  '• Take a few deep breaths',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: viewModel.beginMeditation,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getTypeColor(session.type),
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
              ),
              child: const Text(
                'Begin Meditation',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
        ],
      ),
    );
  }

  Widget _buildMeditationSession(BuildContext context, MeditationViewModel viewModel) {
    final session = viewModel.currentSession!;
    final currentStep = viewModel.currentStep;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _getTypeColor(session.type).withOpacity(0.1),
            _getTypeColor(session.type).withOpacity(0.05),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: viewModel.progressPercentage,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(_getTypeColor(session.type)),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Step ${viewModel.currentStepIndex + 1} of ${session.steps.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const Spacer(),
            
            // Main meditation visual
            if (session.type == MeditationType.breathing)
              _buildBreathingGuide(viewModel)
            else
              _buildMeditationIcon(session.type),
            
            const Spacer(),
            
            // Current instruction
            if (currentStep != null) ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Text(
                  currentStep.instruction,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
            ],
            
            // Time remaining
            Text(
              _formatDuration(viewModel.totalTimeRemaining),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getTypeColor(session.type),
              ),
            ),
            
            if (viewModel.state == MeditationState.paused) ...[
              const SizedBox(height: AppTheme.spacingL),
              const Text(
                'Meditation Paused',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingGuide(MeditationViewModel viewModel) {
    return AnimatedContainer(
      duration: const Duration(seconds: 4),
      width: viewModel.breathingIn ? 200 : 120,
      height: viewModel.breathingIn ? 200 : 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.calmColor.withOpacity(0.3),
        border: Border.all(
          color: AppTheme.calmColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          viewModel.breathingIn ? 'Breathe In' : 'Breathe Out',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.calmColor,
          ),
        ),
      ),
    );
  }

  Widget _buildMeditationIcon(MeditationType type) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getTypeColor(type).withOpacity(0.2),
      ),
      child: Icon(
        _getTypeIcon(type),
        size: 80,
        color: _getTypeColor(type),
      ),
    );
  }

  Widget _buildCompletion(BuildContext context, MeditationViewModel viewModel) {
    final session = viewModel.currentSession!;
    
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          const Spacer(),
          const Icon(
            Icons.check_circle,
            color: AppTheme.successColor,
            size: 80,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          const Text(
            'Meditation Complete',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'You completed ${session.title}',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.psychology,
                  color: AppTheme.successColor,
                  size: 40,
                ),
                const SizedBox(height: AppTheme.spacingM),
                const Text(
                  'Well Done!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                const Text(
                  'You\'ve taken an important step for your mental wellbeing. '
                  'Regular meditation can help reduce stress and improve focus.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
              ),
              child: const Text(
                'Return to Activities',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
        ],
      ),
    );
  }

  Color _getTypeColor(MeditationType type) {
    switch (type) {
      case MeditationType.breathing:
        return AppTheme.calmColor;
      case MeditationType.bodyScroll:
        return AppTheme.relaxColor;
      case MeditationType.mindfulness:
        return AppTheme.primaryColor;
      case MeditationType.loving_kindness:
        return AppTheme.joyColor;
    }
  }

  IconData _getTypeIcon(MeditationType type) {
    switch (type) {
      case MeditationType.breathing:
        return Icons.air;
      case MeditationType.bodyScroll:
        return Icons.accessibility_new;
      case MeditationType.mindfulness:
        return Icons.self_improvement;
      case MeditationType.loving_kindness:
        return Icons.favorite;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}