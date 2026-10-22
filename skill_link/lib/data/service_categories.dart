import 'package:flutter/material.dart';

class ProviderCategory {
  const ProviderCategory({
    required this.name,
    required this.icon,
    this.description,
  });

  final String name;
  final IconData icon;
  final String? description;
}

const providerCategories = [
  ProviderCategory(name: 'All', icon: Icons.apps, description: 'All services'),
  ProviderCategory(
    name: 'Tutoring',
    icon: Icons.school_rounded,
    description: 'Academic tutoring & test prep',
  ),
  ProviderCategory(
    name: 'Photography',
    icon: Icons.camera_alt_rounded,
    description: 'Events, portraits, commercial',
  ),
  ProviderCategory(
    name: 'Electrical',
    icon: Icons.electrical_services_rounded,
    description: 'Wiring, repairs, installations',
  ),
  ProviderCategory(
    name: 'Plumbing',
    icon: Icons.plumbing_rounded,
    description: 'Pipes, leaks, installations',
  ),
  ProviderCategory(
    name: 'Graphic Design',
    icon: Icons.design_services_rounded,
    description: 'Logos, branding, marketing',
  ),
  ProviderCategory(
    name: 'Cleaning',
    icon: Icons.cleaning_services_rounded,
    description: 'Home & office cleaning',
  ),
];

const serviceCategoryNames = [
  'Tutoring',
  'Photography',
  'Electrical',
  'Plumbing',
  'Graphic Design',
  'Cleaning',
];
