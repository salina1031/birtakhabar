import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alerts_provider.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final alertsProvider = context.watch<AlertsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Alerts')),
      body: alertsProvider.isLoading
          ? const LoadingIndicator()
          : alertsProvider.alerts.isEmpty
              ? const EmptyState(
                  icon: Icons.shield_outlined,
                  title: 'No active alerts',
                  subtitle: 'You will be notified immediately if something comes up.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: alertsProvider.alerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => AlertCard(alert: alertsProvider.alerts[i]),
                ),
    );
  }
}
