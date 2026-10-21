/// SkillLink Booking Screen.
/// Form for submitting a booking request.
library;

import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/service_provider.dart';
import '../services/booking_service.dart';
import '../theme/app_colors.dart';
import 'booking_success_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.provider});

  final ServiceProvider provider;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const List<String> _timeSlots = [
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '1:00 PM - 2:00 PM',
    '2:00 PM - 3:00 PM',
    '3:00 PM - 4:00 PM',
    '4:00 PM - 5:00 PM',
    '5:00 PM - 6:00 PM',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  int _durationHours = 1;
  bool _isSubmitting = false;

  BookingService get _bookingService => BookingService.instance;

  @override
  void initState() {
    super.initState();
    // Pre-fill with saved user info
    _nameController.text = _bookingService.savedUserName;
    _phoneController.text = _bookingService.savedUserPhone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  double get _totalCost => widget.provider.price * _durationHours;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now)
          ? now.add(const Duration(days: 1))
          : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a time slot.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Small delay for UX
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Booking? booking;
    try {
      booking = await _bookingService.createBooking(
        provider: widget.provider,
        date: _selectedDate,
        timeSlot: _selectedTime!,
        durationHours: _durationHours,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        serviceLocation: _locationController.text.trim(),
        notes: _detailsController.text.trim(),
      );
    } catch (error) {
      debugPrint('Booking submission failed: $error');
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not save your booking. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => BookingSuccessScreen(booking: booking!),
      ),
    );
  }

  String _formatSelectedDate() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekdayIndex = _selectedDate.weekday - 1;
    return '${weekdays[weekdayIndex]}, ${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.provider;

    return Scaffold(
      appBar: AppBar(title: const Text('Request Booking')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: ClipOval(
                        child: Image.network(
                          provider.imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${provider.profession} • ${provider.formattedPrice}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (provider.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Featured',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Customer Information
              Text(
                'Your Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+251 9XX XXX XXX',
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  final phone = value.trim();
                  // Basic Ethiopian phone validation
                  if (!RegExp(
                    r'^(\+251|0)?9\d{8}$',
                  ).hasMatch(phone.replaceAll(' ', ''))) {
                    return 'Enter a valid Ethiopian phone number (e.g., +251 9XX XXX XXX)';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),

              // Booking Details
              Text(
                'Booking Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Service field (read-only, pre-filled)
              TextFormField(
                initialValue: '${provider.category} — ${provider.profession}',
                decoration: InputDecoration(
                  labelText: 'Service',
                  prefixIcon: const Icon(Icons.work_outline_rounded),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 12),

              // Date picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Preferred Date',
                    prefixIcon: const Icon(Icons.event_outlined),
                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                  child: Text(
                    _formatSelectedDate(),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Time slots
              Text(
                'Preferred Time',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots
                    .map(
                      (slot) => ChoiceChip(
                        selected: _selectedTime == slot,
                        label: Text(slot),
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) => setState(() => _selectedTime = slot),
                        selectedColor: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        checkmarkColor: theme.colorScheme.primary,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),

              // Duration
              Row(
                children: [
                  Text(
                    'Duration',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _durationHours > 1
                        ? () => setState(() => _durationHours--)
                        : null,
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: _durationHours > 1
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.remove_rounded,
                        size: 18,
                        color: _durationHours > 1
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$_durationHours hour${_durationHours > 1 ? 's' : ''}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _durationHours < 8
                        ? () => setState(() => _durationHours++)
                        : null,
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: _durationHours < 8
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: _durationHours < 8
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Service Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Service Location',
                  hintText: 'Address, landmark, or area',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the service location';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Additional Details
              TextFormField(
                controller: _detailsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Details (Optional)',
                  hintText:
                      'Describe the task, specific requirements, access instructions...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes_outlined),
                  ),
                  alignLabelWithHint: true,
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // Price estimate
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimate (${provider.formattedPrice} × $_durationHours)',
                          style: theme.textTheme.bodyLarge,
                        ),
                        Text(
                          'ETB ${_totalCost.toStringAsFixed(0)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Your request will be sent to the provider for confirmation. No payment is collected at this stage.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit Booking Request',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitBooking,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
