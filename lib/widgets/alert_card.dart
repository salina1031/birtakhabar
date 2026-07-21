import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/emergency_alert.dart';
import '../theme/app_theme.dart';

class AlertCard extends StatelessWidget {
  final EmergencyAlert alert;

  const AlertCard({super.key, required this.alert});

  Color get _severityColor {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return AppTheme.emergency;
      case AlertSeverity.warning:
        return const Color(0xFFEF6C00);
      case AlertSeverity.info:
        return AppTheme.accent;
    }
  }

  IconData get _severityIcon {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return Icons.warning_amber_rounded;
      case AlertSeverity.warning:
        return Icons.error_outline;
      case AlertSeverity.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _severityColor.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _severityColor.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_severityIcon, color: _severityColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Text(
                        timeago.format(alert.postedAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(alert.description, style: const TextStyle(fontSize: 13.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(alert.location, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
