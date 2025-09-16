import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import 'journal_view_model.dart';

/// Journaling screen
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => JournalViewModel(),
      child: const _JournalContent(),
    );
  }
}

class _JournalContent extends StatelessWidget {
  const _JournalContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildAppBar(context, viewModel),
          body: viewModel.isEditing 
              ? _buildEditingView(context, viewModel)
              : _buildEntriesView(context, viewModel),
          floatingActionButton: viewModel.isEditing 
              ? null 
              : FloatingActionButton(
                  onPressed: viewModel.startNewEntry,
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, JournalViewModel viewModel) {
    return AppBar(
      title: Text(viewModel.isEditing ? 'Write Entry' : 'Journal'),
      actions: [
        if (viewModel.isEditing) ...[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: viewModel.saveEntry,
            tooltip: 'Save',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: viewModel.cancelEditing,
            tooltip: 'Cancel',
          ),
        ],
      ],
    );
  }

  Widget _buildEntriesView(BuildContext context, JournalViewModel viewModel) {
    if (viewModel.entries.isEmpty) {
      return _buildEmptyState(context, viewModel);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: viewModel.entries.length,
      itemBuilder: (context, index) {
        final entry = viewModel.entries[index];
        return _buildEntryCard(context, entry, viewModel);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, JournalViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Start Your Journal',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Writing in a journal can help you process emotions, track progress, and reflect on your journey.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            ElevatedButton.icon(
              onPressed: viewModel.startNewEntry,
              icon: const Icon(Icons.edit),
              label: const Text('Write First Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingL,
                  vertical: AppTheme.spacingM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, JournalEntry entry, JournalViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Material(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          onTap: () => viewModel.editEntry(entry),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (entry.mood != null) ...[
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: entry.mood!.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                    ],
                    PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'delete') {
                          _showDeleteConfirmation(context, entry, viewModel);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  _formatDate(entry.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                if (entry.content.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    entry.content.length > 150 
                        ? '${entry.content.substring(0, 150)}...'
                        : entry.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (entry.gratitudeItems.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  Wrap(
                    spacing: AppTheme.spacingS,
                    children: entry.gratitudeItems.take(2).map((item) {
                      return Chip(
                        label: Text(
                          item.length > 20 ? '${item.substring(0, 20)}...' : item,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppTheme.joyColor.withOpacity(0.2),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  Wrap(
                    spacing: AppTheme.spacingS,
                    children: entry.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingS,
                          vertical: AppTheme.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditingView(BuildContext context, JournalViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field
          TextField(
            controller: viewModel.titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          // Mood selector
          _buildMoodSelector(context, viewModel),
          const SizedBox(height: AppTheme.spacingL),
          
          // Prompts section
          _buildPromptsSection(context, viewModel),
          const SizedBox(height: AppTheme.spacingL),
          
          // Main content field
          TextField(
            controller: viewModel.contentController,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'What\'s on your mind?',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          // Gratitude section
          _buildGratitudeSection(context, viewModel),
          const SizedBox(height: AppTheme.spacingL),
          
          // Tags section
          _buildTagsSection(context, viewModel),
          const SizedBox(height: AppTheme.spacingXXL),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context, JournalViewModel viewModel) {
    final moods = [
      JournalMood(emotion: 'Happy', intensity: 4, color: AppTheme.joyColor),
      JournalMood(emotion: 'Calm', intensity: 3, color: AppTheme.calmColor),
      JournalMood(emotion: 'Neutral', intensity: 3, color: Colors.grey),
      JournalMood(emotion: 'Sad', intensity: 2, color: AppTheme.sadColor),
      JournalMood(emotion: 'Anxious', intensity: 3, color: AppTheme.anxiousColor),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Wrap(
          spacing: AppTheme.spacingM,
          children: moods.map((mood) {
            final isSelected = viewModel.selectedMood?.emotion == mood.emotion;
            return GestureDetector(
              onTap: () => viewModel.setMood(mood),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? mood.color : mood.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  border: Border.all(
                    color: mood.color,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  mood.emotion,
                  style: TextStyle(
                    color: isSelected ? Colors.white : mood.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPromptsSection(BuildContext context, JournalViewModel viewModel) {
    final categories = ['Reflection', 'Gratitude', 'Creative', 'Mindfulness'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Writing Prompts',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = viewModel.selectedPromptCategory == category;
              return Container(
                margin: const EdgeInsets.only(right: AppTheme.spacingS),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) => viewModel.setPromptCategory(category),
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.currentPrompts.length,
            itemBuilder: (context, index) {
              final prompt = viewModel.currentPrompts[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: AppTheme.spacingM),
                child: Material(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    onTap: () => viewModel.applyPrompt(prompt),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      child: Text(
                        prompt,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGratitudeSection(BuildContext context, JournalViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gratitude List (Optional)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: TextField(
              controller: viewModel.gratitudeControllers[index],
              decoration: InputDecoration(
                labelText: '${index + 1}. Something you\'re grateful for',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.favorite_border),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context, JournalViewModel viewModel) {
    final commonTags = ['work', 'family', 'health', 'goals', 'reflection', 'gratitude'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Wrap(
          spacing: AppTheme.spacingS,
          children: commonTags.map((tag) {
            final isSelected = viewModel.selectedTags.contains(tag);
            return FilterChip(
              label: Text('#$tag'),
              selected: isSelected,
              onSelected: (selected) => viewModel.toggleTag(tag),
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, JournalEntry entry, JournalViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete "${entry.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteEntry(entry.id);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
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