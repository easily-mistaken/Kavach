import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alerts',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AlertCard(
            title: 'Emergency Alert',
            description: 'Send an emergency alert to all your circles',
            icon: Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
            onTap: () {
              _showEmergencyAlertDialog(context);
            },
          ),
          const SizedBox(height: 16),
          _AlertCard(
            title: 'Check-in Request',
            description: 'Request a location update from your circles',
            icon: Icons.location_on_rounded,
            color: Theme.of(context).colorScheme.primary,
            onTap: () {
              // Show check-in request dialog
            },
          ),
          const SizedBox(height: 16),
          _AlertCard(
            title: 'Custom Message',
            description: 'Send a custom message to selected circles',
            icon: Icons.message_rounded,
            color: Theme.of(context).colorScheme.secondary,
            onTap: () {
              // Show custom message dialog
            },
          ),
        ],
      ),
    );
  }

  void _showEmergencyAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Emergency Alert?'),
        content: const Text(
          'This will send an emergency alert to all your circles. Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency alert sent to all circles'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AlertCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(51)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 