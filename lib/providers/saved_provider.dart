import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/news_article.dart';
import '../services/firestore_service.dart';

/// Tracks which articles the signed-in user has bookmarked
/// (Scope 3.3 - Save and Share).
class SavedProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  String? _uid;
  StreamSubscription? _sub;

  SavedProvider(this._firestore);

  Set<String> savedIds = {};
  List<NewsArticle> savedArticles = [];
  bool isLoading = false;

  void bindUser(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _sub?.cancel();
    savedIds = {};
    savedArticles = [];
    if (uid == null) {
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();
    _sub = _firestore.streamSavedIds(uid).listen((ids) async {
      savedIds = ids;
      savedArticles = await _firestore.getSavedArticles(ids);
      isLoading = false;
      notifyListeners();
    });
  }

  bool isSaved(String articleId) => savedIds.contains(articleId);

  Future<void> toggle(NewsArticle article) async {
    if (_uid == null) return;
    if (isSaved(article.id)) {
      await _firestore.unsaveArticle(_uid!, article.id);
    } else {
      await _firestore.saveArticle(_uid!, article);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
