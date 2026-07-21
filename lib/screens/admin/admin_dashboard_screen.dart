import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'admin_review_tips_screen.dart';
import 'admin_post_news_screen.dart';
import 'admin_post_alert_screen.dart';

/// Lightweight in-app content management for administrators/editors,
/// covering the MVP's "basic content management for administrators" item.
/// A full browser-based dashboard (React, per the architecture doc) can
/// reuse the same Firestore collections for a richer desktop workflow.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _AdminTile(
            icon: Icons.fact_check_outlined,
            color: AppTheme.accent,
            title: 'Review Community Tips',
            subtitle: 'Approve or reject submitted news tips',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminReviewTipsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.post_add_outlined,
            color: AppTheme.primary,
            title: 'Publish News Article',
            subtitle: 'Post a new categorized article to the feed',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminPostNewsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.campaign_outlined,
            color: AppTheme.emergency,
            title: 'Post Emergency Alert',
            subtitle: 'Broadcast a verified emergency notification',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminPostAlertScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
