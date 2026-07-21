import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

/// Represents a resident or administrator account.
/// Stored in Firestore under `users/{uid}`.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? ward;
  final UserRole role;
  final List<String> notificationPrefs; // category names the user follows
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.ward,
    this.role = UserRole.resident,
    this.notificationPrefs = const ['local', 'emergency'],
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      ward: map['ward'],
      role: UserRoleX.fromString(map['role'] ?? 'resident'),
      notificationPrefs: List<String>.from(map['notificationPrefs'] ?? ['local', 'emergency']),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'ward': ward,
      'role': role.name,
      'notificationPrefs': notificationPrefs,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
