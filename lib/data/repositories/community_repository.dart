import '../models/community_article.dart';

/// Abstract repository for community content operations
abstract class CommunityRepository {
  /// Get all community articles
  Future<List<CommunityArticle>> getAllArticles({int? limit});
  
  /// Get article by ID
  Future<CommunityArticle?> getArticle(String articleId);
  
  /// Get featured articles
  Future<List<CommunityArticle>> getFeaturedArticles({int limit = 5});
  
  /// Get articles by category
  Future<List<CommunityArticle>> getArticlesByCategory(
    String category, {
    int? limit,
  });
  
  /// Get articles by tags
  Future<List<CommunityArticle>> getArticlesByTags(
    List<String> tags, {
    int? limit,
  });
  
  /// Search articles
  Future<List<CommunityArticle>> searchArticles(
    String query, {
    int? limit,
  });
  
  /// Get recent articles
  Future<List<CommunityArticle>> getRecentArticles({int limit = 10});
  
  /// Get most popular articles
  Future<List<CommunityArticle>> getPopularArticles({int limit = 10});
  
  /// Like an article
  Future<void> likeArticle(String userId, String articleId);
  
  /// Unlike an article
  Future<void> unlikeArticle(String userId, String articleId);
  
  /// Bookmark an article
  Future<void> bookmarkArticle(String userId, String articleId);
  
  /// Remove bookmark from article
  Future<void> removeBookmark(String userId, String articleId);
  
  /// Get user's bookmarked articles
  Future<List<CommunityArticle>> getBookmarkedArticles(String userId);
  
  /// Get user's liked articles
  Future<List<CommunityArticle>> getLikedArticles(String userId);
  
  /// Increment article view count
  Future<void> incrementViewCount(String articleId);
  
  /// Get personalized article recommendations
  Future<List<CommunityArticle>> getPersonalizedArticles(
    String userId, {
    int limit = 5,
  });
}