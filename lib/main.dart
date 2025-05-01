import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

void main() {
  runApp(const AvelaApp());
}

class AvelaApp extends StatelessWidget {
  const AvelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avela',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4EFF),
          primary: const Color(0xFF6B4EFF),
          secondary: const Color(0xFFFF6B6B),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(37.42796133580664, -122.085749655962);
  late Set<Marker> _markers;
  Timer? _locationUpdateTimer;
  bool _isLiveLocation = true;
  int _updateFrequency = 5; // minutes

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  void _initializeMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('user'),
        position: const LatLng(37.42796133580664, -122.085749655962),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(
          title: 'You',
          snippet: 'Current location',
          onTap: () => _showContactInfo('You', '555-0122'),
        ),
      ),
      Marker(
        markerId: const MarkerId('mom'),
        position: const LatLng(37.42896133580664, -122.084749655962),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        infoWindow: InfoWindow(
          title: 'Mom',
          snippet: 'Updated 5 minutes ago',
          onTap: () => _showContactInfo('Mom', '555-0123'),
        ),
      ),
      Marker(
        markerId: const MarkerId('liza'),
        position: const LatLng(37.42696133580664, -122.086749655962),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        infoWindow: InfoWindow(
          title: 'Liza',
          snippet: 'Updated 2 minutes ago',
          onTap: () => _showContactInfo('Liza', '555-0124'),
        ),
      ),
    };
  }

  void _startLocationUpdates() {
    if (_isLiveLocation) {
      _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _updateLocations();
      });
    } else {
      _locationUpdateTimer = Timer.periodic(
        Duration(minutes: _updateFrequency),
        (timer) {
          _updateLocations();
        },
      );
    }
  }

  void _updateLocations() {
    setState(() {
      // Simulate location updates
      _markers = _markers.map((marker) {
        if (marker.markerId.value != 'user') {
          final newPosition = LatLng(
            marker.position.latitude + (0.0001 * (DateTime.now().millisecond % 2 == 0 ? 1 : -1)),
            marker.position.longitude + (0.0001 * (DateTime.now().millisecond % 2 == 0 ? 1 : -1)),
          );
          return marker.copyWith(
            positionParam: newPosition,
            infoWindowParam: InfoWindow(
              title: marker.infoWindow.title,
              snippet: 'Updated just now',
              onTap: () => _showContactInfo(
                marker.infoWindow.title ?? '',
                marker.markerId.value == 'mom' ? '555-0123' : '555-0124',
              ),
            ),
          );
        }
        return marker;
      }).toSet();
    });
  }

  void _showContactInfo(String name, String phoneNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      name == 'You'
                          ? 'https://i.pravatar.cc/150?img=1'
                          : name == 'Mom'
                              ? 'https://i.pravatar.cc/150?img=2'
                              : 'https://i.pravatar.cc/150?img=6',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated just now',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ContactActionButton(
                        icon: Icons.call_outlined,
                        label: 'Call',
                        onPressed: () => _makePhoneCall(phoneNumber),
                      ),
                      _ContactActionButton(
                        icon: Icons.message_outlined,
                        label: 'Message',
                        onPressed: () => _sendMessage(phoneNumber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendMessage(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _showSOSConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send SOS Alert'),
        content: const Text(
          'This will send an emergency alert to all your trusted connections. Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement SOS alert sending
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS alert sent to your trusted connections'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Home Screen with Map
          Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 14.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                markers: _markers,
                mapType: MapType.normal,
              ),
              Positioned(
                top: 60,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    // Avela Branding
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AVELA',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_searching_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Live',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Welcome Message
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/150?img=1',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back, Sarah',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Your family is safe',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Circles Screen
          const CirclesScreen(),
          // Alerts Screen
          const AlertsScreen(),
          // Settings Screen
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Circles',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSOSConfirmation,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.emergency_outlined),
      ),
    );
  }
}

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

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alerts & Updates',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: Text(
              'Mark all read',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withAlpha(51),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AlertItem(
            type: 'info',
            from: 'Mom',
            time: '2 hours ago',
            message: 'I arrived safely at home',
            isRead: false,
          ),
          const SizedBox(height: 12),
          _AlertItem(
            type: 'warning',
            from: 'Anna',
            time: 'Yesterday',
            message: 'Running late, might need a pickup soon',
            isRead: false,
          ),
          const SizedBox(height: 12),
          _AlertItem(
            type: 'emergency',
            from: 'Liza',
            time: '2 days ago',
            message: 'Heading to work, will be back by 6',
            isRead: true,
          ),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String type;
  final String from;
  final String time;
  final String message;
  final bool isRead;

  const _AlertItem({
    required this.type,
    required this.from,
    required this.time,
    required this.message,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color iconColor;
    IconData icon;

    switch (type) {
      case 'info':
        borderColor = Theme.of(context).colorScheme.primary;
        iconColor = Theme.of(context).colorScheme.primary;
        icon = Icons.info_outline;
        break;
      case 'warning':
        borderColor = Colors.amber;
        iconColor = Colors.amber;
        icon = Icons.warning_amber_outlined;
        break;
      case 'emergency':
        borderColor = Colors.red;
        iconColor = Colors.red;
        icon = Icons.error_outline;
        break;
      default:
        borderColor = Theme.of(context).colorScheme.primary;
        iconColor = Theme.of(context).colorScheme.primary;
        icon = Icons.info_outline;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(51)),
      ),
      color: isRead ? Colors.grey[50] : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: borderColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              from,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (!isRead) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withAlpha(26),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          time,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isRead ? FontWeight.normal : FontWeight.w500,
                        color: isRead ? Colors.grey[700] : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _shareLocation = true;
  bool _storeLocationHistory = true;
  bool _preciseLocation = true;
  bool _circleAlerts = true;
  bool _sosNotifications = true;
  bool _appUpdates = true;
  bool _isLiveLocation = true;
  int _updateFrequency = 5;

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
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withAlpha(51)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=1',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sarah Johnson',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'sarah.johnson@example.com',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Privacy & Location Section
          Text(
            'Privacy & Location',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _SettingsSwitchTile(
            title: 'Share My Location',
            subtitle: 'Let your circles see where you are',
            value: _shareLocation,
            onChanged: (value) {
              setState(() {
                _shareLocation = value;
              });
            },
          ),
          _SettingsSwitchTile(
            title: 'Location History',
            subtitle: 'Store your location data for 24 hours',
            value: _storeLocationHistory,
            onChanged: (value) {
              setState(() {
                _storeLocationHistory = value;
              });
            },
          ),
          _SettingsSwitchTile(
            title: 'Precise Location',
            subtitle: 'Show exact position on map',
            value: _preciseLocation,
            onChanged: (value) {
              setState(() {
                _preciseLocation = value;
              });
            },
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withAlpha(51)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Live Location',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Update location in real-time',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  value: _isLiveLocation,
                  onChanged: (value) {
                    setState(() {
                      _isLiveLocation = value;
                    });
                  },
                ),
                if (!_isLiveLocation) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Frequency',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _updateFrequency.toDouble(),
                          min: 1,
                          max: 60,
                          divisions: 59,
                          label: '$_updateFrequency minutes',
                          onChanged: (value) {
                            setState(() {
                              _updateFrequency = value.round();
                            });
                          },
                        ),
                        Text(
                          'Update every $_updateFrequency minutes',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _SettingsSwitchTile(
            title: 'Circle Alerts',
            subtitle: 'When someone in your circle sends an alert',
            value: _circleAlerts,
            onChanged: (value) {
              setState(() {
                _circleAlerts = value;
              });
            },
          ),
          _SettingsSwitchTile(
            title: 'SOS Notifications',
            subtitle: 'Emergency notifications from your circles',
            value: _sosNotifications,
            onChanged: (value) {
              setState(() {
                _sosNotifications = value;
              });
            },
          ),
          _SettingsSwitchTile(
            title: 'App Updates',
            subtitle: 'News and feature updates from Avela',
            value: _appUpdates,
            onChanged: (value) {
              setState(() {
                _appUpdates = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // Emergency Contacts Section
          Text(
            'Emergency Contacts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _EmergencyContactTile(
            name: 'Mom',
            role: 'Primary',
            imageUrl: 'https://i.pravatar.cc/150?img=2',
          ),
          _EmergencyContactTile(
            name: 'Sister',
            imageUrl: 'https://i.pravatar.cc/150?img=3',
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add Emergency Contact'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Log Out Button
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withAlpha(51)),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600]),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _EmergencyContactTile extends StatelessWidget {
  final String name;
  final String? role;
  final String imageUrl;

  const _EmergencyContactTile({
    required this.name,
    this.role,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withAlpha(51)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(name),
        subtitle: role != null ? Text(role!) : null,
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {},
        ),
      ),
    );
  }
}

class _ContactActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ContactActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
