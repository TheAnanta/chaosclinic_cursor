import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/common_widgets.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/community_article.dart';
import 'home_view_model.dart';

/// Main home screen with personalized content
class HomeScreen extends StatefulWidget {
  final UserProfile user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: _buildContent(viewModel),
          ),
          floatingActionButton: _buildQuickMoodFab(viewModel),
        );
      },
    );
  }

  Widget _buildContent(HomeViewModel viewModel) {
    if (viewModel.state == HomeState.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.state == HomeState.error) {
      return EmptyState(
        title: 'Something went wrong',
        message: viewModel.errorMessage ?? 'Unable to load your data',
        icon: Icons.error_outline,
        actionText: 'Try Again',
        onActionPressed: viewModel.refresh,
      );
    }

    return CustomScrollView(
      slivers: [
        _buildAppBar(viewModel),
        SliverPadding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Greeting Section
              _buildGreetingSection(viewModel),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Quick Actions
              _buildQuickActions(viewModel),
              const SizedBox(height: AppTheme.spacingXL),
              
              // AI Message Card
              _buildAiMessageCard(viewModel),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Recommended Activities
              _buildRecommendedActivities(viewModel),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Featured Articles
              _buildFeaturedArticles(viewModel),
              const SizedBox(height: AppTheme.spacingXXL),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(HomeViewModel viewModel) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Row(
                children: [
                  // App logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  
                  // Title
                  const Expanded(
                    child: Text(
                      'Chaos Clinic',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Trusted contact indicator
                  if (viewModel.trustedContactInitial != null)
                    _buildTrustedContactIndicator(viewModel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustedContactIndicator(HomeViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.onTrustedContactTapped,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            viewModel.trustedContactInitial!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          viewModel.userGreeting,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          'How are you feeling today?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(HomeViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.favorite_border,
            title: 'Log Mood',
            color: AppTheme.joyColor,
            onTap: () => _showQuickMoodDialog(viewModel),
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.self_improvement,
            title: 'Activities',
            color: AppTheme.calmColor,
            onTap: () {}, // Navigate to activities
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.article_outlined,
            title: 'Community',
            color: AppTheme.secondaryColor,
            onTap: () {}, // Navigate to community
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiMessageCard(HomeViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.onAiChatTapped,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kanha',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    viewModel.aiWelcomeMessage,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.primaryColor.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedActivities(HomeViewModel viewModel) {
    if (viewModel.recommendedActivities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended for You',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.recommendedActivities.length,
            itemBuilder: (context, index) {
              final activity = viewModel.recommendedActivities[index];
              return _buildActivityCard(activity, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Activity activity, HomeViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.onActivityTapped(activity),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: AppTheme.spacingM),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.getEmotionColor(activity.targetEmotions.isNotEmpty 
                    ? activity.targetEmotions.first 
                    : 'neutral').withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusL),
                  topRight: Radius.circular(AppTheme.radiusL),
                ),
              ),
              child: Icon(
                _getActivityIcon(activity.type),
                size: 40,
                color: AppTheme.getEmotionColor(activity.targetEmotions.isNotEmpty 
                    ? activity.targetEmotions.first 
                    : 'neutral'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    activity.estimatedTimeDisplay,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedArticles(HomeViewModel viewModel) {
    if (viewModel.featuredArticles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community Highlights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...viewModel.featuredArticles.take(3).map((article) {
          return _buildArticleCard(article, viewModel);
        }),
      ],
    );
  }

  Widget _buildArticleCard(CommunityArticle article, HomeViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.onArticleTapped(article),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: const Icon(
                Icons.article_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    '${article.authorName} • ${article.readTimeDisplay}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
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
    );
  }

  Widget _buildQuickMoodFab(HomeViewModel viewModel) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickMoodDialog(viewModel),
      icon: const Icon(Icons.favorite),
      label: const Text('Quick Mood'),
      backgroundColor: AppTheme.primaryColor,
    );
  }

  void _showQuickMoodDialog(HomeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How are you feeling?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmotionSelector(
              selectedEmotion: '',
              onEmotionSelected: (emotion) {
                Navigator.of(context).pop();
                viewModel.logMood(emotion, 3); // Default intensity
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logged $emotion mood'),
                    backgroundColor: AppTheme.getEmotionColor(emotion),
                  ),
                );
              },
              emotions: EmotionOption.defaultEmotions,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.game:
        return Icons.games;
      case ActivityType.meditation:
        return Icons.self_improvement;
      case ActivityType.grounding:
        return Icons.nature;
      case ActivityType.breathing:
        return Icons.air;
      case ActivityType.journaling:
        return Icons.edit_note;
      case ActivityType.education:
        return Icons.school;
    }
  }
}