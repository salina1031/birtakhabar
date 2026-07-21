// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/news_tip.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';

class AdminReviewTipsScreen extends StatefulWidget {
  const AdminReviewTipsScreen({super.key});

  @override
  State<AdminReviewTipsScreen> createState() => _AdminReviewTipsScreenState();
}

class _AdminReviewTipsScreenState extends State<AdminReviewTipsScreen> {
  final _firestore = FirestoreService();

  Future<void> _decide(NewsTip tip, TipStatus status) async {
    await _firestore.reviewTip(tip.id, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tip ${status == TipStatus.approved ? "approved" : "rejected"}.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Tips')),
      body: StreamBuilder<List<NewsTip>>(
        stream: _firestore.streamTips(status: TipStatus.pending),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingIndicator();
          final tips = snapshot.data!;
          if (tips.isEmpty) {
            return const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No pending tips',
              subtitle: 'New community submissions will show up here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tips.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final tip = tips[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tip.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 6),
                      Text(tip.description),
                      const SizedBox(height: 8),
                      Text(
                        'By ${tip.submittedByName} · ${timeago.format(tip.submittedAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _decide(tip, TipStatus.rejected),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Reject'),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade700),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _decide(tip, TipStatus.approved),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
