import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/provider_registration.dart';
import '../services/provider_registration_service.dart';
import 'provider_registration_screen.dart';
import '../widgets/profile_image.dart';

class ProviderRegistrationsScreen extends StatelessWidget {
  const ProviderRegistrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Provider Registration')),
      body: FirebaseAuth.instance.currentUser == null
          ? const Center(child: Text('Please sign in to view registrations.'))
          : StreamBuilder<List<ProviderRegistration>>(
              stream: ProviderRegistrationService.instance
                  .watchOwnerRegistrations(
                    FirebaseAuth.instance.currentUser!.uid,
                  ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load registration status.'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final registrations = snapshot.data!;
                if (registrations.isEmpty) return _EmptyState();
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: registrations.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) =>
                      _RegistrationCard(registration: registrations[index]),
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No provider registrations yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your registration status will update here after review.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProviderRegistrationScreen(),
                ),
              ),
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('Become a Provider'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({required this.registration});

  final ProviderRegistration registration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (registration.status) {
      ProviderRegistrationStatus.pending => theme.colorScheme.tertiary,
      ProviderRegistrationStatus.approved => Colors.green,
      ProviderRegistrationStatus.rejected => theme.colorScheme.error,
    };
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileImage(
                  url: registration.profileImageUrl,
                  initials: registration.fullName
                      .split(RegExp(r'\s+'))
                      .take(2)
                      .map((part) => part.isEmpty ? '' : part[0])
                      .join()
                      .toUpperCase(),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    registration.fullName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    registration.status.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(registration.professionalTitle),
            const SizedBox(height: 8),
            Text(
              '${registration.category} • ${registration.location}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 24),
            Text(
              'Reference: ${registration.reference}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Submitted: ${registration.formattedSubmittedAt}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (registration.status == ProviderRegistrationStatus.rejected &&
                registration.rejectionReason?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                'Rejection reason: ${registration.rejectionReason}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
