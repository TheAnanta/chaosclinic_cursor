import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import 'gratitude_view_model.dart';

/// Gratitude practice screen - focused specifically on gratitude exercises
class GratitudeScreen extends StatelessWidget {
  const GratitudeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GratitudeViewModel(),
      child: const _GratitudeContent(),
    );
  }
}

class _GratitudeContent extends StatelessWidget {
  const _GratitudeContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<GratitudeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gratitude Practice'),
            backgroundColor: AppTheme.joyColor,
            foregroundColor: Colors.white,
          ),
          body: viewModel.isWriting 
              ? _buildGratitudeWriting(context, viewModel)
              : _buildGratitudeHome(context, viewModel),
          floatingActionButton: viewModel.isWriting 
              ? null 
              : FloatingActionButton.extended(
                  onPressed: viewModel.startNewGratitudePractice,
                  icon: const Icon(Icons.favorite),
                  label: const Text('New Practice'),
                  backgroundColor: AppTheme.joyColor,
                ),
        );
      },
    );
  }

  Widget _buildGratitudeHome(BuildContext context, GratitudeViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.joyColor.withOpacity(0.1),
                  AppTheme.joyColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(color: AppTheme.joyColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.favorite,
                  size: 48,
                  color: AppTheme.joyColor,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Daily Gratitude Practice',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.joyColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Taking time to appreciate what we have can improve mood, reduce stress, and increase life satisfaction.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Quick gratitude prompts
          _buildQuickPrompts(context, viewModel),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Previous gratitude entries
          _buildGratitudeHistory(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts(BuildContext context, GratitudeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Gratitude Prompts',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Text(
          'Choose a prompt to get started with your gratitude practice:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...viewModel.gratitudePrompts.map((prompt) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: Material(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              color: Colors.white,
              elevation: 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                onTap: () => viewModel.startWithPrompt(prompt),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.joyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.joyColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Text(
                          prompt,
                          style: Theme.of(context).textTheme.bodyMedium,
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
        }),
      ],
    );
  }

  Widget _buildGratitudeHistory(BuildContext context, GratitudeViewModel viewModel) {
    if (viewModel.gratitudeEntries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Gratitude Journey',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Start Your First Practice',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Your gratitude entries will appear here as you continue your practice.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Gratitude Journey',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...viewModel.gratitudeEntries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: AppTheme.joyColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      _formatDate(entry.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.joyColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                ...entry.gratitudeItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: const BoxDecoration(
                            color: AppTheme.joyColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGratitudeWriting(BuildContext context, GratitudeViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.joyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: Column(
              children: [
                Text(
                  'What are you grateful for today?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.joyColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Take a moment to reflect on the good things in your life, no matter how small.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Active prompt
          if (viewModel.currentPrompt != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      viewModel.currentPrompt!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
          ],
          
          // Gratitude items
          ...List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: TextField(
                controller: viewModel.gratitudeControllers[index],
                decoration: InputDecoration(
                  labelText: '${index + 1}. I am grateful for...',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.favorite_border, color: AppTheme.joyColor),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.joyColor),
                  ),
                ),
                maxLines: 2,
              ),
            );
          }),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: viewModel.cancelWriting,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: viewModel.saveGratitudePractice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.joyColor,
                  ),
                  child: const Text('Save Practice'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}