/// SkillLink booking service.
/// Central app state for bookings with local persistence.
library;

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../models/service_provider.dart';
import 'storage_service.dart';

/// Central app state for bookings. Notifies listeners whenever a booking
/// is created or its status changes. Persists to local storage.
class BookingService extends ChangeNotifier {
  BookingService._internal();

  static final BookingService instance = BookingService._internal();

  factory BookingService() => instance;

  final StorageService _storage = StorageService.instance;
  bool _storageListenerAttached = false;

  List<Booking> get bookings => _storage.bookings;

  List<Booking> get upcomingBookings => _storage.upcomingBookings;

  List<Booking> get pastBookings => _storage.pastBookings;

  List<Booking> getBookingsByStatus(BookingStatus status) {
    return _storage.getBookingsByStatus(status);
  }

  /// Initialize the service (loads from storage)
  Future<void> initialize() async {
    await _storage.initialize();
    if (!_storageListenerAttached) {
      _storage.addListener(_onStorageChanged);
      _storageListenerAttached = true;
    }
  }

  void _onStorageChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _storage.removeListener(_onStorageChanged);
    super.dispose();
  }

  /// Create a new booking request
  Future<Booking> createBooking({
    required ServiceProvider provider,
    required DateTime date,
    required String timeSlot,
    required int durationHours,
    required String customerName,
    required String customerPhone,
    required String serviceLocation,
    String notes = '',
  }) async {
    final booking = Booking(
      id: _nextId,
      reference: _nextReference,
      providerId: provider.id,
      providerName: provider.name,
      providerProfession: provider.profession,
      providerImageUrl: provider.imageUrl,
      serviceName: provider.category,
      customerName: customerName,
      customerPhone: customerPhone,
      preferredDate: date,
      preferredTime: timeSlot,
      serviceLocation: serviceLocation,
      additionalDetails: notes,
      estimatedPrice: provider.price * durationHours,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );
    await _storage.createBooking(booking);

    // Save user info for future bookings
    await _storage.saveUserInfo(name: customerName, phone: customerPhone);
    return booking;
  }

  /// Cancel a booking
  Future<void> cancelBooking(String id) {
    return _storage.cancelBooking(id);
  }

  /// Mark booking as completed
  Future<void> markCompleted(String id) {
    return _storage.completeBooking(id);
  }

  /// Update booking status
  Future<void> updateBookingStatus(String id, BookingStatus status) {
    return _storage.updateBookingStatus(id, status);
  }

  /// Generate a human-readable booking reference
  String generateReference() {
    final rand = Random.secure();
    return 'SL${rand.nextInt(90000) + 10000}';
  }

  String get _nextId => 'b${DateTime.now().microsecondsSinceEpoch}';

  String get _nextReference {
    String reference;
    do {
      reference = generateReference();
    } while (_storage.bookings.any(
      (booking) => booking.reference == reference,
    ));
    return reference;
  }

  /// Get user's saved name
  String get savedUserName => _storage.userName;

  /// Get user's saved phone
  String get savedUserPhone => _storage.userPhone;
}
