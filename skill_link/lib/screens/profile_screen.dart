import 'package:flutter/material.dart';

import '../services/booking_service.dart';
import 'my_bookings_screen.dart';
import 'premium_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = BookingService.instance;
    final name = service.savedUserName.isEmpty
        ? 'SkillLink Guest'
        : service.savedUserName;
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Local demo profile · no account or authentication',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 28),
          _ProfileEntry(
            icon: Icons.event_note_outlined,
            title: 'My Bookings',
            subtitle: 'View and manage your requests',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MyBookingsScreen()),
            ),
          ),
          _ProfileEntry(
            icon: Icons.storefront_outlined,
            title: 'Promote Your Services',
            subtitle: 'Reach more customers with SkillLink',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PremiumScreen()),
            ),
          ),
          _ProfileEntry(
            icon: Icons.help_outline_rounded,
            title: 'Help and Support',
            subtitle: 'Questions about the SkillLink demo',
            onTap: () => _showInfo(
              context,
              'Help and Support',
              'For this MVP, support is provided through the demo presentation.',
            ),
          ),
          _ProfileEntry(
            icon: Icons.info_outline_rounded,
            title: 'About SkillLink',
            subtitle: 'Find trusted local services near you',
            onTap: () => _showInfo(
              context,
              'About SkillLink',
              'SkillLink is a local-services marketplace concept for Addis Ababa. Provider profiles and bookings in this demo use local sample data.',
            ),
          ),
          _ProfileEntry(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Information',
            subtitle: 'Bookings are stored locally on this device',
            onTap: () => _showInfo(
              context,
              'Privacy Information',
              'This MVP does not use authentication or collect payments. Booking requests are persisted locally on the device.',
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ProfileEntry extends StatelessWidget {
  const _ProfileEntry({
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
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
