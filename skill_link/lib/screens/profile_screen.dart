import 'package:flutter/material.dart';

import '../services/booking_service.dart';
import 'my_bookings_screen.dart';
import 'premium_screen.dart';
import 'provider_registration_screen.dart';
import 'provider_registrations_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingService = BookingService.instance;
    final name = bookingService.savedUserName;
    final initials = name.isEmpty
        ? 'SL'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part[0])
              .join()
              .toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      initials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? 'SkillLink guest' : name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Local demo profile',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ProfileAction(
            icon: Icons.event_note_outlined,
            title: 'My Bookings',
            subtitle: 'View and manage your booking requests',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MyBookingsScreen()),
            ),
          ),
          _ProfileAction(
            icon: Icons.storefront_outlined,
            title: 'Grow Your Business',
            subtitle: 'Get discovered by more local customers',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PremiumScreen()),
            ),
          ),
          _ProfileAction(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Register as a Service Provider',
            subtitle: 'Showcase your skills and reach more customers.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProviderRegistrationScreen(),
              ),
            ),
          ),
          _ProfileAction(
            icon: Icons.assignment_outlined,
            title: 'My Provider Registration',
            subtitle: 'View registrations saved on this device',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProviderRegistrationsScreen(),
              ),
            ),
          ),
          _ProfileAction(
            icon: Icons.help_outline_rounded,
            title: 'Help and Support',
            subtitle: 'Demo support information',
            onTap: () => _showInfo(
              context,
              'Help and Support',
              'For this local MVP, support contact details are not connected yet.',
            ),
          ),
          _ProfileAction(
            icon: Icons.info_outline_rounded,
            title: 'About SkillLink',
            subtitle: 'Find trusted local services near you',
            onTap: () => _showInfo(
              context,
              'About SkillLink',
              'SkillLink is a local-services marketplace demo for Addis Ababa.',
            ),
          ),
          _ProfileAction(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Information',
            subtitle: 'Bookings are stored locally on this device',
            onTap: () => _showInfo(
              context,
              'Privacy Information',
              'This MVP does not use authentication. Booking information is stored locally on the device.',
            ),
          ),
        ],
      ),
    );
  }

  static void _showInfo(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
