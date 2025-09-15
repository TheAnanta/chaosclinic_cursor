import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_article.freezed.dart';
part 'community_article.g.dart';

@freezed
class CommunityArticle with _$CommunityArticle {
  const factory CommunityArticle({
    required String id,
    required String title,
    required String subtitle,
    required String authorName,
    required String authorImageUrl,
    required String headerImageUrl,
    required String content,
    @Default([]) List<String> tags,
    required int readTimeInMinutes,
    @Default(0) int likes,
    @Default(0) int views,
    @Default(false) bool isBookmarked,
    @Default(false) bool isLiked,
    DateTime? publishedAt,
    DateTime? updatedAt,
    String? category,
    @Default(ArticleStatus.published) ArticleStatus status,
  }) = _CommunityArticle;

  factory CommunityArticle.fromJson(Map<String, Object?> json) =>
      _$CommunityArticleFromJson(json);
}

enum ArticleStatus {
  draft,
  published,
  archived,
}

/// Extension methods for CommunityArticle
extension CommunityArticleExtensions on CommunityArticle {
  /// Get formatted read time
  String get readTimeDisplay {
    if (readTimeInMinutes <= 1) {
      return '1 min read';
    } else {
      return '$readTimeInMinutes min read';
    }
  }

  /// Get formatted publish date
  String get publishDateDisplay {
    if (publishedAt == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(publishedAt!);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return '${difference.inHours}h ago';
      }
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  /// Get formatted likes count
  String get likesDisplay {
    if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}k';
    } else {
      return likes.toString();
    }
  }

  /// Get formatted views count
  String get viewsDisplay {
    if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}k';
    } else {
      return views.toString();
    }
  }

  /// Check if article is recent (published within last 7 days)
  bool get isRecent {
    if (publishedAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(publishedAt!);
    return difference.inDays <= 7;
  }
}