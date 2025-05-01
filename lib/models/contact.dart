import 'package:google_maps_flutter/google_maps_flutter.dart';

class Contact {
  final String id;
  final String name;
  final String? phoneNumber;
  final String imageUrl;
  final bool isGroup;
  final int? memberCount;
  final LatLng? location;
  final DateTime? lastUpdate;

  Contact({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.imageUrl,
    this.isGroup = false,
    this.memberCount,
    this.location,
    this.lastUpdate,
  });
} 