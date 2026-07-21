import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertSeverity { info, warning, critical }

extension AlertSeverityX on AlertSeverity {
  String get label {
    switch (this) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  static AlertSeverity fromString(String value) {
    return AlertSeverity.values.firstWhere(
      (s) => s.name == value,
      orElse: () => AlertSeverity.info,
    );
  }
}

/// A verified emergency notification, kept in its own dedicated channel
/// separate from the general news feed (see Literature Review re: Bhandari, 2025).
/// Stored in Firestore under `alerts/{id}`.
class EmergencyAlert {
  final String id;
  final String title;
  final String description;
  final String location; // e.g. "Ward 5, Birtamode"
  final AlertSeverity severity;
  final String postedBy;
  final DateTime postedAt;
  final bool isActive;

  EmergencyAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.severity,
    required this.postedBy,
    required this.postedAt,
    this.isActive = true,
  });

  factory EmergencyAlert.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return EmergencyAlert(
      id: doc.id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? 'Birtamode',
      severity: AlertSeverityX.fromString(map['severity'] ?? 'info'),
      postedBy: map['postedBy'] ?? 'BirtaKhabar Admin',
      postedAt: (map['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'severity': severity.name,
      'postedBy': postedBy,
      'postedAt': Timestamp.fromDate(postedAt),
      'isActive': isActive,
    };
  }
}
