import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/emergency_alert.dart';
import '../services/firestore_service.dart';

/// Drives the emergency alerts channel, kept separate from the general news
/// feed so urgent notices are never buried (see Scope 3.3 - Emergency Alerts).
class AlertsProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  AlertsProvider(this._firestore) {
    _sub = _firestore.streamAlerts().listen((data) {
      alerts = data;
      isLoading = false;
      notifyListeners();
    });
  }

  List<EmergencyAlert> alerts = [];
  bool isLoading = true;
  StreamSubscription? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
