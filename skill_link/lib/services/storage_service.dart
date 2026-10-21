/// SkillLink local storage service.
/// Handles persistence of bookings using SharedPreferences.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking.dart';

class StorageService extends ChangeNotifier {
  StorageService._internal();

  static final StorageService instance = StorageService._internal();

  factory StorageService() => instance;

  static const String _bookingsKey = 'skilllink_bookings';
  static const String _userNameKey = 'skilllink_user_name';
  static const String _userPhoneKey = 'skilllink_user_phone';

  List<Booking> _bookings = [];
  String _userName = '';
  String _userPhone = '';
  bool _initialized = false;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  String get userName => _userName;
  String get userPhone => _userPhone;
  bool get isInitialized => _initialized;

  /// Initialize the storage service and load saved data
  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Load bookings
    final bookingsJson = prefs.getString(_bookingsKey);
    if (bookingsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(bookingsJson);
        _bookings = decoded
            .whereType<Map<String, dynamic>>()
            .map((item) {
              try {
                return _bookingFromJson(item);
              } catch (error) {
                debugPrint('Skipping invalid saved booking: $error');
                return null;
              }
            })
            .whereType<Booking>()
            .toList();
        // Sort by creation date, newest first
        _bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (e) {
        debugPrint('Error loading bookings: $e');
        _bookings = [];
      }
    }

    // Load user info
    _userName = prefs.getString(_userNameKey) ?? '';
    _userPhone = prefs.getString(_userPhoneKey) ?? '';

    _initialized = true;
    notifyListeners();
  }

  /// Save bookings to local storage
  Future<void> _saveBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = json.encode(_bookings.map(_bookingToJson).toList());
    await prefs.setString(_bookingsKey, bookingsJson);
  }

  /// Save user info
  Future<void> saveUserInfo({String? name, String? phone}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) {
      _userName = name;
      await prefs.setString(_userNameKey, name);
    }
    if (phone != null) {
      _userPhone = phone;
      await prefs.setString(_userPhoneKey, phone);
    }
    notifyListeners();
  }

  /// Create a new booking
  Future<void> createBooking(Booking booking) async {
    _bookings.insert(0, booking);
    try {
      await _saveBookings();
    } catch (error) {
      _bookings.remove(booking);
      debugPrint('Error saving booking: $error');
      rethrow;
    }
    notifyListeners();
  }

  /// Update booking status
  Future<void> updateBookingStatus(String id, BookingStatus status) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      final previous = _bookings[index];
      _bookings[index] = _bookings[index].copyWith(status: status);
      try {
        await _saveBookings();
      } catch (error) {
        _bookings[index] = previous;
        debugPrint('Error saving booking status: $error');
        rethrow;
      }
      notifyListeners();
    }
  }

  /// Cancel a booking (sets status to cancelled)
  Future<void> cancelBooking(String id) {
    return updateBookingStatus(id, BookingStatus.cancelled);
  }

  /// Mark booking as completed
  Future<void> completeBooking(String id) {
    return updateBookingStatus(id, BookingStatus.completed);
  }

  /// Get bookings by status
  List<Booking> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((b) => b.status == status).toList();
  }

  /// Get upcoming bookings (pending + confirmed)
  List<Booking> get upcomingBookings => _bookings
      .where(
        (b) =>
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.confirmed,
      )
      .toList();

  /// Get past bookings (completed + cancelled)
  List<Booking> get pastBookings => _bookings
      .where(
        (b) =>
            b.status == BookingStatus.completed ||
            b.status == BookingStatus.cancelled,
      )
      .toList();

  /// Clear all bookings (for testing/reset)
  Future<void> clearAllBookings() async {
    _bookings.clear();
    await _saveBookings();
    notifyListeners();
  }

  /// Convert Booking to JSON
  Map<String, dynamic> _bookingToJson(Booking booking) {
    return {
      'id': booking.id,
      'reference': booking.reference,
      'providerId': booking.providerId,
      'providerName': booking.providerName,
      'providerProfession': booking.providerProfession,
      'providerImageUrl': booking.providerImageUrl,
      'serviceName': booking.serviceName,
      'customerName': booking.customerName,
      'customerPhone': booking.customerPhone,
      'preferredDate': booking.preferredDate.toIso8601String(),
      'preferredTime': booking.preferredTime,
      'serviceLocation': booking.serviceLocation,
      'additionalDetails': booking.additionalDetails,
      'estimatedPrice': booking.estimatedPrice,
      'status': booking.status.name,
      'createdAt': booking.createdAt.toIso8601String(),
    };
  }

  /// Convert JSON to Booking
  Booking _bookingFromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      reference: json['reference'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      providerProfession: json['providerProfession'] as String,
      providerImageUrl: json['providerImageUrl'] as String,
      serviceName: json['serviceName'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      preferredDate: DateTime.parse(json['preferredDate'] as String),
      preferredTime: json['preferredTime'] as String,
      serviceLocation: json['serviceLocation'] as String,
      additionalDetails: json['additionalDetails'] as String,
      estimatedPrice: (json['estimatedPrice'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
