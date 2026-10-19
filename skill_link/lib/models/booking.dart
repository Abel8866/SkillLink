import 'package:flutter/material.dart';

@immutable
class Booking {
  const Booking({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.providerProfession,
    required this.providerImageUrl,
    required this.serviceName,
    required this.date,
    required this.timeSlot,
    required this.totalCost,
    required this.status,
    this.notes = '',
  });

  final String id;
  final String providerId;
  final String providerName;
  final String providerProfession;
  final String providerImageUrl;
  final String serviceName;
  final DateTime date;
  final String timeSlot;
  final double totalCost;
  final BookingStatus status;
  final String notes;

  Booking copyWith({BookingStatus? status}) {
    return Booking(
      id: id,
      providerId: providerId,
      providerName: providerName,
      providerProfession: providerProfession,
      providerImageUrl: providerImageUrl,
      serviceName: serviceName,
      date: date,
      timeSlot: timeSlot,
      totalCost: totalCost,
      notes: notes,
      status: status ?? this.status,
    );
  }

  String get formattedDate =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String get formattedCost => '\$${totalCost.toStringAsFixed(0)}';
}

enum BookingStatus { upcoming, completed, cancelled }
