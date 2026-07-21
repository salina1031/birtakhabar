import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../admin/admin_dashboard_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 28, color: AppTheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Text(user.email, style: TextStyle(color: Colors.grey.shade600)),
          ),
          if (user.isAdmin)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Administrator', style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          const SizedBox(height: 24),
          const _SectionTitle('Notification Preferences'),
          const SizedBox(height: 8),
          _NotificationPrefs(user: user),
          const SizedBox(height: 24),
          if (user.isAdmin) ...[
            const _SectionTitle('Administration'),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.dashboard_customize_outlined, color: AppTheme.accent),
                title: const Text('Admin Dashboard'),
                subtitle: const Text('Review tips, publish news & alerts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          OutlinedButton.icon(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout, color: AppTheme.primary),
            label: const Text('Log Out', style: TextStyle(color: AppTheme.primary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey));
  }
}

class _NotificationPrefs extends StatefulWidget {
  final dynamic user;
  const _NotificationPrefs({required this.user});

  @override
  State<_NotificationPrefs> createState() => _NotificationPrefsState();
}

class _NotificationPrefsState extends State<_NotificationPrefs> {
  final _authService = AuthService();
  final _notificationService = NotificationService();
  late Set<String> _selected = Set.from(widget.user.notificationPrefs);

  Future<void> _toggle(String category, bool value) async {
    setState(() {
      if (value) {
        _selected.add(category);
      } else {
        _selected.remove(category);
      }
    });
    await _authService.updateNotificationPrefs(widget.user.uid, _selected.toList());
    if (value) {
      await _notificationService.subscribeToCategory(category);
    } else {
      await _notificationService.unsubscribeFromCategory(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ...NewsCategory.values.map(
            (c) => SwitchListTile(
              title: Text(c.label),
              value: _selected.contains(c.name),
              activeColor: AppTheme.primary,
              onChanged: (v) => _toggle(c.name, v),
            ),
          ),
        ],
      ),
    );
  }
}
