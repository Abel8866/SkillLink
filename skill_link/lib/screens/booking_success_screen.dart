/// SkillLink Booking Success Screen.
/// Confirmation screen shown after submitting a booking request.
library;

import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../theme/app_colors.dart';
import 'my_bookings_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.booking});

  final Booking booking;

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Booking Submitted'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Success animation/icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 60,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),

              // Success heading
              Text(
                'Request Submitted!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your request is saved on this device for provider confirmation.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Booking details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking reference
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Booking Reference',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            booking.reference,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Provider info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: ClipOval(
                            child: Image.network(
                              booking.providerImageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.person_rounded,
                                size: 24,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.providerName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                booking.providerProfession,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Details grid
                    _DetailRow(
                      icon: Icons.work_outline_rounded,
                      label: 'Service',
                      value: booking.serviceName,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.event_outlined,
                      label: 'Date',
                      value: _formatDate(booking.preferredDate),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: booking.preferredTime,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.attach_money_rounded,
                      label: 'Estimated Price',
                      value: booking.formattedPrice,
                      valueStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Status
                    Row(
                      children: [
                        Icon(
                          Icons.pending_rounded,
                          size: 20,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Status: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Pending Confirmation',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  icon: const Icon(Icons.list_alt_rounded),
                  label: const Text(
                    'View My Bookings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const MyBookingsScreen(initialTab: 0),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.home_rounded),
                  label: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => _HomePageWrapper(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Note
              Text(
                'The provider will contact you shortly to confirm the booking. You can track the status in My Bookings.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: valueStyle ?? theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

/// Wrapper to navigate back to home with proper tab
class _HomePageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This will be handled by the main app's navigation
    return const _HomePageRedirect();
  }
}

class _HomePageRedirect extends StatefulWidget {
  const _HomePageRedirect();

  @override
  State<_HomePageRedirect> createState() => _HomePageRedirectState();
}

class _HomePageRedirectState extends State<_HomePageRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Navigate to home tab (index 0)
      // The main app handles this via its bottom navigation
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
