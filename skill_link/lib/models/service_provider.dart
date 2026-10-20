/// SkillLink service provider model.
/// Represents a local service professional available for booking.
library;

import 'package:flutter/material.dart';

@immutable
class ServiceProvider {
  const ServiceProvider({
    required this.id,
    required this.name,
    required this.profession,
    required this.category,
    required this.description,
    required this.location,
    required this.price,
    required this.priceUnit,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.imageUrl,
    required this.isFeatured,
    required this.isVerified,
    this.availability,
  });

  final String id;
  final String name;
  final String profession;
  final String category;
  final String description;
  final String location;
  final double price;
  final String priceUnit; // e.g., '/hour', '/session', '/project', '/service'
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final String imageUrl;
  final bool isFeatured;
  final bool isVerified;
  final String? availability; // e.g., 'Mon-Fri 9AM-6PM'

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  String get formattedPrice {
    return 'ETB ${price.toStringAsFixed(0)}$priceUnit';
  }

  String get shortLocation {
    // Extract neighborhood/area from location
    if (location.contains(',')) {
      return location.split(',').first.trim();
    }
    return location;
  }

  ServiceProvider copyWith({
    String? id,
    String? name,
    String? profession,
    String? category,
    String? description,
    String? location,
    double? price,
    String? priceUnit,
    double? rating,
    int? reviewCount,
    int? experienceYears,
    String? imageUrl,
    bool? isFeatured,
    bool? isVerified,
    String? availability,
  }) {
    return ServiceProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      profession: profession ?? this.profession,
      category: category ?? this.category,
      description: description ?? this.description,
      location: location ?? this.location,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      experienceYears: experienceYears ?? this.experienceYears,
      imageUrl: imageUrl ?? this.imageUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      isVerified: isVerified ?? this.isVerified,
      availability: availability ?? this.availability,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceProvider &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
