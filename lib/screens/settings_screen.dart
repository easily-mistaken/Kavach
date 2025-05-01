import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLiveLocation = true;
  int _updateFrequency = 5;
  bool _isLocationSharingEnabled = true;
  bool _isNotificationsEnabled = true;
  bool _isEmergencyContactsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Section
          _SettingsSection(
            title: 'Profile',
            children: [
              ListTile(
                leading: const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=1',
                  ),
                ),
                title: Text(
                  'Sarah Johnson',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  'sarah.johnson@example.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    // Navigate to edit profile
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Location Settings Section
          _SettingsSection(
            title: 'Location Settings',
            children: [
              SwitchListTile(
                title: const Text('Live Location'),
                subtitle: Text(
                  'Update location in real-time',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                value: _isLiveLocation,
                onChanged: (value) {
                  setState(() {
                    _isLiveLocation = value;
                  });
                },
              ),
              if (!_isLiveLocation) ...[
                ListTile(
                  title: const Text('Update Frequency'),
                  subtitle: Text(
                    '$_updateFrequency minutes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  trailing: DropdownButton<int>(
                    value: _updateFrequency,
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5 minutes')),
                      DropdownMenuItem(value: 15, child: Text('15 minutes')),
                      DropdownMenuItem(value: 30, child: Text('30 minutes')),
                      DropdownMenuItem(value: 60, child: Text('1 hour')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _updateFrequency = value;
                        });
                      }
                    },
                  ),
                ),
              ],
              SwitchListTile(
                title: const Text('Location Sharing'),
                subtitle: Text(
                  'Share your location with circles',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                value: _isLocationSharingEnabled,
                onChanged: (value) {
                  setState(() {
                    _isLocationSharingEnabled = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Privacy Settings Section
          _SettingsSection(
            title: 'Privacy',
            children: [
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: Text(
                  'Receive alerts and updates',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                value: _isNotificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _isNotificationsEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Emergency Contacts'),
                subtitle: Text(
                  'Share location with emergency contacts',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                value: _isEmergencyContactsEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEmergencyContactsEnabled = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Account Section
          _SettingsSection(
            title: 'Account',
            children: [
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Log Out'),
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () {
                  // Show logout confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text(
                        'Are you sure you want to log out?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Handle logout
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withAlpha(51)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
} 