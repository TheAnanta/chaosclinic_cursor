import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/themes/app_theme.dart';
import 'community_view_model.dart';
import 'article_screen.dart';

/// Community screen with articles, stories, and user interactions
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CommunityViewModel(),
      child: const _CommunityContent(),
    );
  }
}

class _CommunityContent extends StatelessWidget {
  const _CommunityContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Community'),
            backgroundColor: AppTheme.secondaryColor,
            foregroundColor: Colors.white,
          ),
          body: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  color: AppTheme.secondaryColor,
                  child: const TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(text: 'Articles', icon: Icon(Icons.article)),
                      Tab(text: 'Stories', icon: Icon(Icons.auto_stories)),
                      Tab(text: 'Users', icon: Icon(Icons.people)),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildArticlesTab(context, viewModel),
                      _buildStoriesTab(context, viewModel),
                      _buildUsersTab(context, viewModel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArticlesTab(BuildContext context, CommunityViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured article
          if (viewModel.featuredArticle != null) ...[
            _buildFeaturedArticle(context, viewModel.featuredArticle!, viewModel),
            const SizedBox(height: AppTheme.spacingXL),
          ],
          
          // Articles section
          Text(
            'Latest Stories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          ...viewModel.articles.map((article) {
            return _buildArticleCard(context, article, viewModel);
          }),
        ],
      ),
    );
  }

  Widget _buildFeaturedArticle(BuildContext context, Article article, CommunityViewModel viewModel) {
    return GestureDetector(
      onTap: () => _navigateToArticle(context, article),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.secondaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Title and description
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    article.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // Author and read time
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          article.emotionalAttribute[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        '${article.duration} min read',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Article article, CommunityViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Material(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          onTap: () => _navigateToArticle(context, article),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Article image placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getEmotionColor(article.emotionalAttribute).withOpacity(0.3),
                        _getEmotionColor(article.emotionalAttribute).withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      article.emotionalAttribute[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getEmotionColor(article.emotionalAttribute),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                
                // Article content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        article.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      
                      // Tags and metadata
                      Wrap(
                        spacing: AppTheme.spacingS,
                        runSpacing: AppTheme.spacingXS,
                        children: [
                          ...article.tags.take(2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingS,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      
                      // Duration and emotion
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${article.duration} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getEmotionColor(article.emotionalAttribute),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            article.emotionalAttribute,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getEmotionColor(article.emotionalAttribute),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesTab(BuildContext context, CommunityViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add story button
          Container(
            width: double.infinity,
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
            child: Column(
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Share Your Story',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Your journey can inspire and help others. Share your experience with the community.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingM),
                ElevatedButton(
                  onPressed: () => viewModel.showNewStorySheet(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Add Story'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Stories list
          Text(
            'Community Stories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          if (viewModel.stories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingXL),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_stories,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      'No stories yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Be the first to share your story!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...viewModel.stories.map((story) {
              return _buildStoryCard(context, story, viewModel);
            }),
        ],
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, Story story, CommunityViewModel viewModel) {
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
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  story.username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.username,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTimestamp(story.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            story.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context, CommunityViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: viewModel.users.length,
      itemBuilder: (context, index) {
        final user = viewModel.users[index];
        return _buildUserCard(context, user, viewModel);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, CommunityUser user, CommunityViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Material(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        color: Colors.white,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  user.username[0].toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.isFollowed ? 'Following' : 'Community Member',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => viewModel.toggleFollow(user),
                style: OutlinedButton.styleFrom(
                  foregroundColor: user.isFollowed ? Colors.grey : AppTheme.primaryColor,
                  side: BorderSide(
                    color: user.isFollowed ? Colors.grey : AppTheme.primaryColor,
                  ),
                ),
                child: Text(user.isFollowed ? 'Following' : 'Follow'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToArticle(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleScreen(article: article),
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'courage':
        return Colors.orange;
      case 'anxious':
        return Colors.purple;
      case 'empowering':
        return Colors.green;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
}