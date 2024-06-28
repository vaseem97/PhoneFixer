import 'package:flutter/material.dart';

class Service {
  final IconData icon;
  final String title;

  String description;

  Service({
    required this.icon,
    required this.title,
    required this.description,
  });
}

final List<Service> repairServices = [
  Service(
    icon: Icons.phone_iphone,
    title: 'Screen Replacement',
    description: '6 Month Warrnty',
  ),
  Service(
    icon: Icons.battery_full,
    title: 'Battery Replacement',
    description: '6 Month Warrnty',
  ),
  Service(
    icon: Icons.safety_check,
    title: 'Software Issues',
    description: '6 Month Warrnty',
  ),
  Service(
    icon: Icons.hardware,
    title: 'Hardware Repair',
    description: '6 Month Warrnty',
  ),
  Service(
    icon: Icons.face,
    title: 'Face ID Repair',
    description: '6 Month Warrnty',
  ),
  Service(
    icon: Icons.camera_alt,
    title: 'Camera Repair',
    description: '6 Month Warrnty',
  ),
  Service(
    icon: Icons.five_g,
    title: 'Back Glass Replacement',
    description: '6 Month Warrnty',
  ),
  Service(
    icon: Icons.volume_up,
    title: 'Speaker Repair',
    description: '6 Month Warrnty',
  ),
];
