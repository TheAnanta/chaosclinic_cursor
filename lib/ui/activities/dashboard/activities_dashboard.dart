import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../word_search/word_search_screen.dart';
import '../bug_smash/bug_smash_screen.dart';
import '../meditation/meditation_screen.dart';
import '../journaling/journal_screen.dart';

/// Activities dashboard showing all available activities
class ActivitiesDashboard extends StatelessWidget {
  const ActivitiesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Activity',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Engage in activities designed to support your mental wellbeing',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            
            // Games Section
            _buildSection(
              context,
              'Games & Interactive',
              'Fun activities to distract and engage your mind',
              [
                _ActivityCard(
                  title: 'Word Search',
                  description: 'Find hidden words in relaxing puzzle games',
                  icon: Icons.grid_view,
                  color: AppTheme.calmColor,
                  estimatedTime: '5-10 min',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const WordSearchScreen()),
                  ),
                ),
                _ActivityCard(
                  title: 'Bug Smash',
                  description: 'Release stress by smashing worry bugs',
                  icon: Icons.bug_report,
                  color: AppTheme.joyColor,
                  estimatedTime: '3-5 min',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const BugSmashScreen()),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Mindfulness Section
            _buildSection(
              context,
              'Mindfulness & Meditation',
              'Practices to center yourself and find inner peace',
              [
                _ActivityCard(
                  title: 'Guided Meditation',
                  description: 'Various meditation sessions for different needs',
                  icon: Icons.self_improvement,
                  color: AppTheme.relaxColor,
                  estimatedTime: '5-15 min',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MeditationScreen()),
                  ),
                ),
                _ActivityCard(
                  title: 'Breathing Exercises',
                  description: 'Simple breathing techniques to reduce stress',
                  icon: Icons.air,
                  color: AppTheme.calmColor,
                  estimatedTime: '2-5 min',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MeditationScreen()),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Journaling Section
            _buildSection(
              context,
              'Reflection & Writing',
              'Express your thoughts and process your emotions',
              [
                _ActivityCard(
                  title: 'Journal Writing',
                  description: 'Write your thoughts and reflect on your day',
                  icon: Icons.book,
                  color: AppTheme.primaryColor,
                  estimatedTime: '5-20 min',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const JournalScreen()),
                  ),
                ),
                _ActivityCard(
                  title: 'Gratitude Practice',
                  description: 'Focus on what you\'re grateful for',
                  icon: Icons.favorite,
                  color: AppTheme.joyColor,
                  estimatedTime: '3-5 min',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const JournalScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    List<Widget> activities,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppTheme.spacingM,
          crossAxisSpacing: AppTheme.spacingM,
          childAspectRatio: 0.8,
          children: activities,
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String estimatedTime;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.estimatedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(AppTheme.radiusL),
      color: Colors.white,
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Expanded(
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: AppTheme.spacingXS),
                  Text(
                    estimatedTime,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}