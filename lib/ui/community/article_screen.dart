import 'package:flutter/material.dart';
import '../core/themes/app_theme.dart';
import 'community_view_model.dart';

/// Screen to display full article content
class ArticleScreen extends StatelessWidget {
  final Article article;

  const ArticleScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildArticleHeader(context),
                const SizedBox(height: AppTheme.spacingXL),
                _buildArticleContent(context),
                const SizedBox(height: AppTheme.spacingXXL),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: _getEmotionColor(article.emotionalAttribute),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          article.emotionalAttribute,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getEmotionColor(article.emotionalAttribute),
                _getEmotionColor(article.emotionalAttribute).withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      article.emotionalAttribute[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${article.duration} min read',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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

  Widget _buildArticleHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          article.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        
        // Description
        Text(
          article.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        
        // Tags
        if (article.tags.isNotEmpty) ...[
          Wrap(
            spacing: AppTheme.spacingS,
            runSpacing: AppTheme.spacingS,
            children: article.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: _getEmotionColor(article.emotionalAttribute).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  border: Border.all(
                    color: _getEmotionColor(article.emotionalAttribute).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: _getEmotionColor(article.emotionalAttribute),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.spacingL),
        ],
        
        // Article metadata
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getEmotionColor(article.emotionalAttribute).withOpacity(0.2),
                child: Text(
                  article.emotionalAttribute[0].toUpperCase(),
                  style: TextStyle(
                    color: _getEmotionColor(article.emotionalAttribute),
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
                      'Shared by the community',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Real story, real experiences',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.verified,
                color: _getEmotionColor(article.emotionalAttribute),
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Story',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        
        ...article.content.asMap().entries.map((entry) {
          final index = entry.key;
          final paragraph = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
            child: _buildParagraph(context, paragraph, index),
          );
        }),
        
        // Closing section
        const SizedBox(height: AppTheme.spacingXL),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getEmotionColor(article.emotionalAttribute).withOpacity(0.1),
                _getEmotionColor(article.emotionalAttribute).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          child: Column(
            children: [
              Icon(
                Icons.favorite,
                size: 48,
                color: _getEmotionColor(article.emotionalAttribute),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Thank you for sharing your story',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getEmotionColor(article.emotionalAttribute),
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Stories like this help create a supportive community where everyone can learn and grow together.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParagraph(BuildContext context, String paragraph, int index) {
    // Check if this is a quote or special formatting
    if (paragraph.contains('\n\n') && paragraph.contains('Am I') || paragraph.contains('Did I')) {
      // This looks like a series of questions - format specially
      final lines = paragraph.split('\n');
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border(
            left: BorderSide(
              color: _getEmotionColor(article.emotionalAttribute),
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines.map((line) {
            if (line.trim().isEmpty) return const SizedBox(height: 4);
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line.trim(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    // Check if this is a key takeaway or conclusion
    if (paragraph.toLowerCase().contains('takeaway') || 
        paragraph.toLowerCase().contains('my takeaway') ||
        index == article.content.length - 1) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getEmotionColor(article.emotionalAttribute).withOpacity(0.1),
              _getEmotionColor(article.emotionalAttribute).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: _getEmotionColor(article.emotionalAttribute).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (paragraph.toLowerCase().contains('takeaway')) ...[
              Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: _getEmotionColor(article.emotionalAttribute),
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Key Takeaway',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getEmotionColor(article.emotionalAttribute),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
            ],
            Text(
              paragraph,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                fontWeight: paragraph.toLowerCase().contains('takeaway') 
                    ? FontWeight.w500 
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    // Regular paragraph
    return Text(
      paragraph,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        height: 1.6,
        color: Colors.grey.shade800,
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
}