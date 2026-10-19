import 'package:flutter/material.dart';

import '../models/service_provider.dart';
import '../services/booking_service.dart';
import 'my_bookings_screen.dart';

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
    '2:00 PM - 4:00 PM',
    '4:00 PM - 6:00 PM',
  ];

  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  int _durationHours = 1;

  double get _totalCost => widget.provider.hourlyRate * _durationHours;

  BookingService get _bookingService => BookingService.instance;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now)
          ? now.add(const Duration(days: 1))
          : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _confirmBooking() {
    final time = _selectedTime;
    if (time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot first.'),
        ),
      );
      return;
    }

    _bookingService.createBooking(
      provider: widget.provider,
      date: _selectedDate,
      timeSlot: time,
      durationHours: _durationHours,
      notes: _notesController.text.trim(),
    );

    final reference = _bookingService.generateReference();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking confirmed! Reference $reference.'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const MyBookingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.provider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking'),
      ),
      body: SingleChildScrollView(
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
                      provider.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.person, size: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${provider.category} · \$${provider.hourlyRate.toStringAsFixed(0)}/hr',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Select date',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == DateTime.now()
                          ? 'Today'
                          : _formatSelectedDate(),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select time slot',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Duration',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: _durationHours > 1
                      ? () => setState(() => _durationHours--)
                      : null,
                  icon: CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.remove,
                      size: 18,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_durationHours hour${_durationHours > 1 ? 's' : ''}',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _durationHours < 8
                      ? () => setState(() => _durationHours++)
                      : null,
                  icon: CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.add,
                      size: 18,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Notes for the provider (optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the task, parking details, etc…',
                filled: true,
                fillColor:
                    theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimate (\$${provider.hourlyRate.toStringAsFixed(0)} × $_durationHours)',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  '\$${_totalCost.toStringAsFixed(0)}',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: _confirmBooking,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSelectedDate() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    final weekdayIndex = _selectedDate.weekday - 1;
    return '${weekdays[weekdayIndex]}, ${months[_selectedDate.month - 1]} '
        '${_selectedDate.day} (${_selectedDate.year})';
  }
}
