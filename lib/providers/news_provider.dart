import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/news_article.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

/// Drives the categorized news feed (Scope 3.3 - Categorized News Feed).
class NewsProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  NewsProvider(this._firestore) {
    _subscribe();
  }

  NewsCategory? selectedCategory; // null = "All"
  List<NewsArticle> articles = [];
  bool isLoading = true;
  StreamSubscription? _sub;

  void _subscribe() {
    isLoading = true;
    notifyListeners();
    _sub?.cancel();
    _sub = _firestore.streamNews(category: selectedCategory).listen((data) {
      articles = data;
      isLoading = false;
      notifyListeners();
    });
  }

  void selectCategory(NewsCategory? category) {
    if (selectedCategory == category) return;
    selectedCategory = category;
    _subscribe();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
