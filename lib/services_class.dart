import 'package:flutter/material.dart';

class Service {
  final IconData icon;
  final String title;

  Service({
    required this.icon,
    required this.title,
  });
}

final List<Service> repairServices = [
  Service(
    icon: Icons.phone_iphone,
    title: 'Screen Replacement',
  ),
  Service(
    icon: Icons.battery_full,
    title: 'Battery Replacement',
  ),
  Service(
    icon: Icons.safety_check,
    title: 'Software Issues',
  ),
  Service(
    icon: Icons.hardware,
    title: 'Hardware Repair',
  ),
  Service(
    icon: Icons.face,
    title: 'Face ID Repair',
  ),
  Service(
    icon: Icons.camera_alt,
    title: 'Camera Repair',
  ),
  Service(
    icon: Icons.five_g,
    title: 'Back Glass Replacement',
  ),
  Service(
    icon: Icons.volume_up,
    title: 'Speaker Repair',
  ),
];
