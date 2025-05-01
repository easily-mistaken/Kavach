import 'package:flutter/material.dart';
import '../models/contact.dart';

class CirclesScreen extends StatelessWidget {
  const CirclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Circles',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          FilledButton.icon(
            onPressed: () {
              // Show add circle/contact dialog
            },
            icon: const Icon(Icons.add),
            label: const Text('Create'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Groups Section
            Text(
              'Groups',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _CircleCard(
              name: 'Family',
              members: 4,
              imageUrl: 'https://i.pravatar.cc/150?img=2',
              isGroup: true,
            ),
            const SizedBox(height: 12),
            _CircleCard(
              name: 'Close Friends',
              members: 3,
              imageUrl: 'https://i.pravatar.cc/150?img=3',
              isGroup: true,
            ),
            const SizedBox(height: 12),
            _CircleCard(
              name: 'Work Team',
              members: 5,
              imageUrl: 'https://i.pravatar.cc/150?img=4',
              isGroup: true,
            ),
            const SizedBox(height: 24),

            // Individual Contacts Section
            Text(
              'Individual Contacts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _CircleCard(
              name: 'Mom',
              imageUrl: 'https://i.pravatar.cc/150?img=5',
              isGroup: false,
            ),
            const SizedBox(height: 12),
            _CircleCard(
              name: 'Liza',
              imageUrl: 'https://i.pravatar.cc/150?img=6',
              isGroup: false,
            ),
            const SizedBox(height: 12),
            _CircleCard(
              name: 'John',
              imageUrl: 'https://i.pravatar.cc/150?img=7',
              isGroup: false,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _CircleCard extends StatelessWidget {
  final String name;
  final int? members;
  final String imageUrl;
  final bool isGroup;

  const _CircleCard({
    required this.name,
    this.members,
    required this.imageUrl,
    required this.isGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(51)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: isGroup
            ? Text(
                '$members members',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.message_outlined),
              onPressed: () {
                // Open chat
              },
            ),
            IconButton(
              icon: const Icon(Icons.call_outlined),
              onPressed: () {
                // Make call
              },
            ),
          ],
        ),
        onTap: () {
          // Navigate to circle/contact details
        },
      ),
    );
  }
} 