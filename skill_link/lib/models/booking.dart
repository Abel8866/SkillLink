/// SkillLink booking model.
/// Represents a booking request submitted by a customer.
library;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum BookingStatus {
  pending('Pending', 'Pending Confirmation'),
  confirmed('Confirmed', 'Confirmed'),
  completed('Completed', 'Completed'),
  cancelled('Cancelled', 'Cancelled');

  const BookingStatus(this.label, this.detailLabel);

  final String label;
  final String detailLabel;
}

@immutable
class Booking {
  const Booking({
    required this.id,
    required this.reference,
    required this.providerId,
    required this.providerName,
    required this.providerProfession,
    required this.providerImageUrl,
    required this.serviceName,
    required this.customerName,
    required this.customerPhone,
    required this.preferredDate,
    required this.preferredTime,
    required this.serviceLocation,
    required this.additionalDetails,
    required this.estimatedPrice,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String reference; // Human-readable reference like SL12345
  final String providerId;
  final String providerName;
  final String providerProfession;
  final String providerImageUrl;
  final String serviceName;
  final String customerName;
  final String customerPhone;
  final DateTime preferredDate;
  final String preferredTime;
  final String serviceLocation;
  final String additionalDetails;
  final double estimatedPrice;
  final BookingStatus status;
  final DateTime createdAt;

  String get formattedDate {
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
    return '${preferredDate.day} ${months[preferredDate.month - 1]} ${preferredDate.year}';
  }

  String get formattedTime => preferredTime;

  String get formattedPrice => 'ETB ${estimatedPrice.toStringAsFixed(0)}';

  String get formattedCreatedAt {
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
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  Color getStatusColor(ThemeData theme) {
    return switch (status) {
      BookingStatus.pending => AppColors.warning,
      BookingStatus.confirmed => theme.colorScheme.primary,
      BookingStatus.completed => AppColors.success,
      BookingStatus.cancelled => theme.colorScheme.error,
    };
  }

  String getStatusLabel() => status.label;
  String getStatusDetailLabel() => status.detailLabel;

  bool get isCancellable => status == BookingStatus.pending;

  Booking copyWith({
    String? id,
    String? reference,
    String? providerId,
    String? providerName,
    String? providerProfession,
    String? providerImageUrl,
    String? serviceName,
    String? customerName,
    String? customerPhone,
    DateTime? preferredDate,
    String? preferredTime,
    String? serviceLocation,
    String? additionalDetails,
    double? estimatedPrice,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerProfession: providerProfession ?? this.providerProfession,
      providerImageUrl: providerImageUrl ?? this.providerImageUrl,
      serviceName: serviceName ?? this.serviceName,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTime: preferredTime ?? this.preferredTime,
      serviceLocation: serviceLocation ?? this.serviceLocation,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Booking && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
