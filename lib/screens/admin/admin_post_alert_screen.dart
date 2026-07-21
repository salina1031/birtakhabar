import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/emergency_alert.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class AdminPostAlertScreen extends StatefulWidget {
  const AdminPostAlertScreen({super.key});

  @override
  State<AdminPostAlertScreen> createState() => _AdminPostAlertScreenState();
}

class _AdminPostAlertScreenState extends State<AdminPostAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(text: 'Birtamode');
  final _firestore = FirestoreService();
  AlertSeverity _severity = AlertSeverity.warning;
  bool _submitting = false;

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Broadcast alert?'),
        content: const Text('This will immediately notify all subscribed residents.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.emergency),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      final alert = EmergencyAlert(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim().isEmpty ? 'Birtamode' : _locationController.text.trim(),
        severity: _severity,
        postedBy: user.name,
        postedAt: DateTime.now(),
      );
      await _firestore.postAlert(alert);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert broadcast.')));
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Emergency Alert'), backgroundColor: AppTheme.emergency),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<AlertSeverity>(
                  initialValue: _severity,
                  decoration: const InputDecoration(labelText: 'Severity'),
                  items: AlertSeverity.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _severity = v!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Alert title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter an alert title' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Affected location / ward'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emergency),
                  onPressed: _submitting ? null : _publish,
                  child: _submitting
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Review & Broadcast'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
