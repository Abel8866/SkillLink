import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../models/service_provider.dart';
import '../data/sample_providers.dart';

/// Central app state for bookings. Notifies listeners whenever a booking
/// is created or its status changes.
class BookingService extends ChangeNotifier {
  BookingService._internal();

  static final BookingService instance = BookingService._internal();

  factory BookingService() => instance;

  final List<Booking> _bookings = [
    Booking(
      id: 'b0001',
      providerId: sampleProviders[3].id,
      providerName: sampleProviders[3].name,
      providerProfession: sampleProviders[3].profession,
      providerImageUrl: sampleProviders[3].imageUrl,
      serviceName: sampleProviders[3].category,
      date: DateTime.now().add(const Duration(days: 2)),
      timeSlot: '2:00 PM - 4:00 PM',
      totalCost: sampleProviders[3].hourlyRate * 2,
      status: BookingStatus.upcoming,
      notes: 'Kick-off meeting for the app prototype.',
    ),
    Booking(
      id: 'b0002',
      providerId: sampleProviders[2].id,
      providerName: sampleProviders[2].name,
      providerProfession: sampleProviders[2].profession,
      providerImageUrl: sampleProviders[2].imageUrl,
      serviceName: sampleProviders[2].category,
      date: DateTime.now().subtract(const Duration(days: 7)),
      timeSlot: '10:00 AM - 11:00 AM',
      totalCost: sampleProviders[2].hourlyRate,
      status: BookingStatus.completed,
      notes: 'Calculus review session.',
    ),
    Booking(
      id: 'b0003',
      providerId: sampleProviders[6].id,
      providerName: sampleProviders[6].name,
      providerProfession: sampleProviders[6].profession,
      providerImageUrl: sampleProviders[6].imageUrl,
      serviceName: sampleProviders[6].category,
      date: DateTime.now().subtract(const Duration(days: 21)),
      timeSlot: '4:00 PM - 6:00 PM',
      totalCost: sampleProviders[6].hourlyRate * 2,
      status: BookingStatus.cancelled,
      notes: '',
    ),
  ];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  List<Booking> get upcomingBookings =>
      _bookings.where((b) => b.status == BookingStatus.upcoming).toList();

  List<Booking> get pastBookings => _bookings
      .where((b) =>
          b.status == BookingStatus.completed ||
          b.status == BookingStatus.cancelled)
      .toList();

  void createBooking({
    required ServiceProvider provider,
    required DateTime date,
    required String timeSlot,
    required int durationHours,
    String notes = '',
  }) {
    final booking = Booking(
      id: 'b$_nextId',
      providerId: provider.id,
      providerName: provider.name,
      providerProfession: provider.profession,
      providerImageUrl: provider.imageUrl,
      serviceName: provider.category,
      date: date,
      timeSlot: timeSlot,
      totalCost: provider.hourlyRate * durationHours,
      status: BookingStatus.upcoming,
      notes: notes,
    );
    _bookings.insert(0, booking);
    notifyListeners();
  }

  void cancelBooking(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index == -1) return;
    _bookings[index] = _bookings[index].copyWith(status: BookingStatus.cancelled);
    notifyListeners();
  }

  void markCompleted(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index == -1) return;
    _bookings[index] = _bookings[index].copyWith(status: BookingStatus.completed);
    notifyListeners();
  }

  String generateReference() {
    final rand = Random.secure();
    return 'SL${rand.nextInt(90000) + 10000}';
  }

  int get _nextId => _bookings.length + 1;
}
