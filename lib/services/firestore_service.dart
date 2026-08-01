import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_article.dart';
import '../models/emergency_alert.dart';
import '../models/news_tip.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- News feed ----------------

  Stream<List<NewsArticle>> streamNews({NewsCategory? category}) {
    Query<Map<String, dynamic>> query = _db
        .collection(FirestoreCollections.news)
        .orderBy('publishedAt', descending: true);
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }
    return query.snapshots().map(
      (snap) => snap.docs.map((d) => NewsArticle.fromDoc(d)).toList(),
    );
  }

  Future<NewsArticle> getArticle(String id) async {
    final doc = await _db.collection(FirestoreCollections.news).doc(id).get();
    if (!doc.exists) throw Exception('Article not found');
    return NewsArticle.fromDoc(doc);
  }

  Future<void> incrementViewCount(String id) async {
    await _db.collection(FirestoreCollections.news).doc(id).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  Future<void> publishArticle(NewsArticle article) async {
    await _db.collection(FirestoreCollections.news).add(article.toMap());
  }

  Future<void> deleteArticle(String id) async {
    await _db.collection(FirestoreCollections.news).doc(id).delete();
  }

  // ---------------- Emergency alerts ----------------

  Stream<List<EmergencyAlert>> streamAlerts({bool activeOnly = true}) {
    Query<Map<String, dynamic>> query = _db
        .collection(FirestoreCollections.alerts)
        .orderBy('postedAt', descending: true);
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }
    return query.snapshots().map(
      (snap) => snap.docs.map((d) => EmergencyAlert.fromDoc(d)).toList(),
    );
  }

  Future<void> postAlert(EmergencyAlert alert) async {
    await _db.collection(FirestoreCollections.alerts).add(alert.toMap());
  }

  Future<void> deactivateAlert(String id) async {
    await _db.collection(FirestoreCollections.alerts).doc(id).update({'isActive': false});
  }

  // ---------------- Community news tips ----------------

  Future<void> submitTip(NewsTip tip) async {
    await _db.collection(FirestoreCollections.newsTips).doc(tip.id).set(tip.toMap());
  }

  Stream<List<NewsTip>> streamTips({TipStatus? status}) {
    Query<Map<String, dynamic>> query = _db
        .collection(FirestoreCollections.newsTips)
        .orderBy('submittedAt', descending: true);
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    return query.snapshots().map(
      (snap) => snap.docs.map((d) => NewsTip.fromDoc(d)).toList(),
    );
  }

  Future<void> reviewTip(String id, TipStatus status, {String? note}) async {
    await _db.collection(FirestoreCollections.newsTips).doc(id).update({
      'status': status.name,
      if (note != null) 'reviewNote': note,
    });
  }

  // ---------------- Saved / bookmarked articles ----------------

  Future<void> saveArticle(String uid, NewsArticle article) async {
    await _db
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection('saved')
        .doc(article.id)
        .set({'savedAt': FieldValue.serverTimestamp()});
  }

  Future<void> unsaveArticle(String uid, String articleId) async {
    await _db
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection('saved')
        .doc(articleId)
        .delete();
  }

  Stream<Set<String>> streamSavedIds(String uid) {
    return _db
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection('saved')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  Future<List<NewsArticle>> getSavedArticles(Set<String> ids) async {
    if (ids.isEmpty) return [];
    final idList = ids.toList();
    final articles = <NewsArticle>[];
    for (var i = 0; i < idList.length; i += 30) {
      final chunk = idList.sublist(i, i + 30 > idList.length ? idList.length : i + 30);
      final snap = await _db
          .collection(FirestoreCollections.news)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      articles.addAll(snap.docs.map((d) => NewsArticle.fromDoc(d)));
    }
    return articles;
  }
}