/// SkillLink My Bookings Screen.
/// Booking history with status filters and management.
library;

import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../services/booking_service.dart';
import '../theme/app_colors.dart';
import 'explore_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final BookingService _bookingService = BookingService.instance;

  static const List<_BookingFilter> _filters = [
    _BookingFilter(label: 'All', status: null),
    _BookingFilter(label: 'Pending', status: BookingStatus.pending),
    _BookingFilter(label: 'Confirmed', status: BookingStatus.confirmed),
    _BookingFilter(label: 'Completed', status: BookingStatus.completed),
    _BookingFilter(label: 'Cancelled', status: BookingStatus.cancelled),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _filters.length,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, _filters.length - 1),
    );
    _tabController.addListener(_onTabChanged);
    _bookingService.addListener(_onBookingsChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _bookingService.removeListener(_onBookingsChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  void _onBookingsChanged() {
    if (mounted) setState(() {});
  }

  List<Booking> _getFilteredBookings() {
    final filter = _filters[_tabController.index];
    if (filter.status == null) {
      return _bookingService.bookings;
    }
    return _bookingService.getBookingsByStatus(filter.status!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookings = _getFilteredBookings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: theme.colorScheme.outlineVariant,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          labelStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          tabs: _filters.map((f) => Tab(text: f.label)).toList(),
        ),
      ),
      body: bookings.isEmpty
          ? _buildEmptyState(theme, _filters[_tabController.index].label)
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _BookingTile(booking: bookings[index]),
              ),
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String filterLabel) {
    final isAllFilter = filterLabel == 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 48,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isAllFilter ? 'No bookings yet' : 'No $filterLabel bookings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAllFilter
                  ? 'Bookings you make will appear here.'
                  : 'Try a different filter or make a new booking.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (isAllFilter) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.explore_rounded),
                  label: const Text(
                    'Explore Services',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ExploreScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingFilter {
  const _BookingFilter({required this.label, required this.status});

  final String label;
  final BookingStatus? status;
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});

  final Booking booking;

  BookingService get _service => BookingService.instance;

  void _onCancelRequested(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: Text(
          'This will cancel your booking request with ${booking.providerName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep Booking'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _service.cancelBooking(booking.id);
                if (!context.mounted) return;
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled.'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (error) {
                debugPrint('Booking cancellation failed: $error');
                if (!context.mounted) return;
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'We could not update this booking. Please try again.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  void _onViewDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingDetailSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusColor = booking.getStatusColor(theme);
    final statusLabel = booking.getStatusLabel();

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onViewDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    child: ClipOval(
                      child: Image.network(
                        booking.providerImageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.person_rounded,
                          size: 26,
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
                          overflow: TextOverflow.ellipsis,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Reference and service
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number_rounded,
                    size: 15,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    booking.reference,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.work_outline_rounded,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.serviceName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Date, time, price
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 15,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(booking.formattedDate, style: theme.textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(booking.formattedTime, style: theme.textTheme.bodySmall),
                  const Spacer(),
                  Text(
                    booking.formattedPrice,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),

              if (booking.additionalDetails.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  '"${booking.additionalDetails}"',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              if (booking.isCancellable) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _onCancelRequested(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(
                          color: theme.colorScheme.error.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingDetailSheet extends StatelessWidget {
  const _BookingDetailSheet({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = booking.getStatusColor(theme);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            child: ClipOval(
                              child: Image.network(
                                booking.providerImageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.person_rounded,
                                  size: 30,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.providerName,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  booking.providerProfession,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              booking.getStatusDetailLabel(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Reference
                      _DetailItem(
                        icon: Icons.confirmation_number_rounded,
                        label: 'Booking Reference',
                        value: booking.reference,
                        valueStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Service
                      _DetailItem(
                        icon: Icons.work_outline_rounded,
                        label: 'Service',
                        value: booking.serviceName,
                      ),
                      const SizedBox(height: 16),

                      // Date & Time
                      _DetailItem(
                        icon: Icons.event_outlined,
                        label: 'Date',
                        value: booking.formattedDate,
                      ),
                      const SizedBox(height: 16),

                      _DetailItem(
                        icon: Icons.access_time_rounded,
                        label: 'Time',
                        value: booking.formattedTime,
                      ),
                      const SizedBox(height: 16),

                      // Location
                      if (booking.serviceLocation.isNotEmpty) ...[
                        _DetailItem(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: booking.serviceLocation,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Price
                      _DetailItem(
                        icon: Icons.attach_money_rounded,
                        label: 'Estimated Price',
                        value: booking.formattedPrice,
                        valueStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Customer info
                      _DetailItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Customer Name',
                        value: booking.customerName,
                      ),
                      const SizedBox(height: 16),

                      _DetailItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: booking.customerPhone,
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      if (booking.additionalDetails.isNotEmpty) ...[
                        _DetailItem(
                          icon: Icons.notes_outlined,
                          label: 'Additional Details',
                          value: booking.additionalDetails,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Created at
                      _DetailItem(
                        icon: Icons.history_rounded,
                        label: 'Requested On',
                        value: booking.formattedCreatedAt,
                        valueStyle: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      if (booking.isCancellable) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel Booking'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: theme.colorScheme.error.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showCancelDialog(context);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: Text(
          'This will cancel your booking request with ${booking.providerName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep Booking'),
          ),
          FilledButton(
            onPressed: () {
              BookingService.instance.cancelBooking(booking.id);
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Booking cancelled.'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
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
        const SizedBox(width: 14),
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
