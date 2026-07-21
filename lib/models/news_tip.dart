import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

/// A community-submitted news tip awaiting editorial review
/// (see Scope 3.3 - Community News Tips; Literature Review re: Paudel, 2022
/// on the need for verification before publishing).
/// Stored in Firestore under `newsTips/{id}`.
class NewsTip {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String submittedByName;
  final String submittedByUid;
  final String? contactPhone;
  final DateTime submittedAt;
  final TipStatus status;
  final String? reviewNote;

  NewsTip({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.submittedByName,
    required this.submittedByUid,
    this.contactPhone,
    required this.submittedAt,
    this.status = TipStatus.pending,
    this.reviewNote,
  });

  factory NewsTip.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return NewsTip(
      id: doc.id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      submittedByName: map['submittedByName'] ?? 'Anonymous',
      submittedByUid: map['submittedByUid'] ?? '',
      contactPhone: map['contactPhone'],
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: TipStatusX.fromString(map['status'] ?? 'pending'),
      reviewNote: map['reviewNote'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'submittedByName': submittedByName,
      'submittedByUid': submittedByUid,
      'contactPhone': contactPhone,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'status': status.name,
      'reviewNote': reviewNote,
    };
  }
}
