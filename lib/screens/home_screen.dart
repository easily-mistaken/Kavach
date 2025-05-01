import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../widgets/branding_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(37.42796133580664, -122.085749655962);
  late Set<Marker> _markers;
  Timer? _locationUpdateTimer;
  bool _isLiveLocation = true;
  int _updateFrequency = 5;
  int _selectedIndex = 0;

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
        markerId: const MarkerId('liza'),
        position: const LatLng(37.42896133580664, -122.084749655962),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        infoWindow: InfoWindow(
          title: 'Liza',
          snippet: 'Updated 2 minutes ago',
          onTap: () => _showContactInfo('Liza', '555-0124'),
        ),
      ),
      Marker(
        markerId: const MarkerId('mom'),
        position: const LatLng(37.42696133580664, -122.086749655962),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        infoWindow: InfoWindow(
          title: 'Mom',
          snippet: 'Updated just now',
          onTap: () => _showContactInfo('Mom', '555-0123'),
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
              snippet: marker.markerId.value == 'mom' ? 'Updated just now' : 'Updated 2 minutes ago',
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
    final bool isUser = name == 'You';
    
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
                    isUser 
                        ? 'Current location' 
                        : name == 'Mom' 
                            ? 'Updated just now' 
                            : 'Updated 2 minutes ago',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (!isUser) ...[
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
                  ],
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS alert sent to your trusted connections'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
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
      body: Stack(
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
                const BrandingHeader(),
                const SizedBox(height: 12),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showSOSConfirmation,
        backgroundColor: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.emergency_outlined),
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