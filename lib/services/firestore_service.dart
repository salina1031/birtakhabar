// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_article.dart';
import '../models/emergency_alert.dart';
import '../models/news_tip.dart';
import '../utils/constants.dart';

/// Central data access layer for BirtaKhabar's Firestore collections.
/// Corresponds to the "Data Layer" of the system architecture (Cloud Firestore).
class FirestoreService {
  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  // TODO: Restore Firestore usage when billing is available and Firestore is enabled.

  // ---------------- News feed ----------------

  Stream<List<NewsArticle>> streamNews({NewsCategory? category}) {
    // Firestore is disabled; return an empty stream as a safe fallback.
    print('FirestoreService: streamNews called but Firestore is disabled. Returning empty list stream.');
    return Stream.value(<NewsArticle>[]);
  }

  Future<NewsArticle> getArticle(String id) async {
    // Firestore disabled: cannot fetch article. Return a failed future.
    print('FirestoreService: getArticle skipped (Firestore disabled) for id=$id');
    return Future.error('Firestore disabled');
  }

  Future<void> incrementViewCount(String id) async {
    // No-op while Firestore is disabled.
    print('FirestoreService: incrementViewCount skipped (Firestore disabled) for id=$id');
  }

  Future<void> publishArticle(NewsArticle article) async {
    print('FirestoreService: publishArticle skipped (Firestore disabled)');
  }

  Future<void> deleteArticle(String id) async {
    print('FirestoreService: deleteArticle skipped (Firestore disabled) id=$id');
  }

  // ---------------- Emergency alerts ----------------

  Stream<List<EmergencyAlert>> streamAlerts({bool activeOnly = true}) {
    print('FirestoreService: streamAlerts called but Firestore is disabled. Returning empty list stream.');
    return Stream.value(<EmergencyAlert>[]);
  }

  Future<void> postAlert(EmergencyAlert alert) async {
    print('FirestoreService: postAlert skipped (Firestore disabled)');
  }

  Future<void> deactivateAlert(String id) async {
    print('FirestoreService: deactivateAlert skipped (Firestore disabled) id=$id');
  }

  // ---------------- Community news tips ----------------

  Future<void> submitTip(NewsTip tip) async {
    print('FirestoreService: submitTip skipped (Firestore disabled)');
  }

  Stream<List<NewsTip>> streamTips({TipStatus? status}) {
    print('FirestoreService: streamTips called but Firestore is disabled. Returning empty list stream.');
    return Stream.value(<NewsTip>[]);
  }

  Future<void> reviewTip(String id, TipStatus status, {String? note}) async {
    print('FirestoreService: reviewTip skipped (Firestore disabled) id=$id');
  }

  // ---------------- Saved / bookmarked articles ----------------
  // Stored per-user at users/{uid}/saved/{articleId}

  Future<void> saveArticle(String uid, NewsArticle article) async {
    print('FirestoreService: saveArticle skipped (Firestore disabled) uid=$uid article=${article.id}');
  }

  Future<void> unsaveArticle(String uid, String articleId) async {
    print('FirestoreService: unsaveArticle skipped (Firestore disabled) uid=$uid articleId=$articleId');
  }

  Stream<Set<String>> streamSavedIds(String uid) {
    print('FirestoreService: streamSavedIds called but Firestore is disabled. Returning empty set stream.');
    return Stream.value(<String>{});
  }

  Future<List<NewsArticle>> getSavedArticles(Set<String> ids) async {
    if (ids.isEmpty) return [];
    print('FirestoreService: getSavedArticles skipped (Firestore disabled)');
    return [];
  }
}
