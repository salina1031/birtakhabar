import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

/// A published news article. Stored in Firestore under `news/{id}`.
class NewsArticle {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final NewsCategory category;
  final String authorName;
  final String authorId;
  final DateTime publishedAt;
  final bool isVerified;
  final int viewCount;

  NewsArticle({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.category,
    required this.authorName,
    required this.authorId,
    required this.publishedAt,
    this.isVerified = true,
    this.viewCount = 0,
  });

  String get summary =>
      body.length > 140 ? '${body.substring(0, 140).trim()}…' : body;

  factory NewsArticle.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return NewsArticle(
      id: doc.id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      imageUrl: map['imageUrl'],
      category: NewsCategoryX.fromString(map['category'] ?? 'local'),
      authorName: map['authorName'] ?? 'BirtaKhabar Desk',
      authorId: map['authorId'] ?? '',
      publishedAt: (map['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: map['isVerified'] ?? true,
      viewCount: map['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'category': category.name,
      'authorName': authorName,
      'authorId': authorId,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'isVerified': isVerified,
      'viewCount': viewCount,
    };
  }
}
