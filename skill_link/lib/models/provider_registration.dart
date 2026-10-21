import 'package:flutter/material.dart';

enum ProviderRegistrationStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected');

  const ProviderRegistrationStatus(this.label);

  final String label;
}

@immutable
class ProviderRegistration {
  const ProviderRegistration({
    required this.id,
    required this.reference,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.location,
    required this.category,
    required this.professionalTitle,
    required this.experienceYears,
    required this.description,
    required this.price,
    required this.pricingUnit,
    required this.availability,
    required this.submittedAt,
    required this.status,
  });

  final String id;
  final String reference;
  final String fullName;
  final String phone;
  final String email;
  final String location;
  final String category;
  final String professionalTitle;
  final int experienceYears;
  final String description;
  final double? price;
  final String pricingUnit;
  final String availability;
  final DateTime submittedAt;
  final ProviderRegistrationStatus status;

  String get formattedPrice => price == null
      ? 'Negotiable'
      : 'ETB ${price!.toStringAsFixed(0)} / $pricingUnit';

  String get formattedSubmittedAt {
    const months = [
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
    return '${submittedAt.day} ${months[submittedAt.month - 1]} ${submittedAt.year}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'location': location,
        'category': category,
        'professionalTitle': professionalTitle,
        'experienceYears': experienceYears,
        'description': description,
        'price': price,
        'pricingUnit': pricingUnit,
        'availability': availability,
        'submittedAt': submittedAt.toIso8601String(),
        'status': status.name,
      };

  factory ProviderRegistration.fromJson(Map<String, dynamic> json) {
    return ProviderRegistration(
      id: json['id'] as String,
      reference: json['reference'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String? ?? '',
      location: json['location'] as String,
      category: json['category'] as String,
      professionalTitle: json['professionalTitle'] as String,
      experienceYears: (json['experienceYears'] as num).toInt(),
      description: json['description'] as String,
      price: (json['price'] as num?)?.toDouble(),
      pricingUnit: json['pricingUnit'] as String,
      availability: json['availability'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      status: ProviderRegistrationStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => ProviderRegistrationStatus.pending,
      ),
    );
  }
}
