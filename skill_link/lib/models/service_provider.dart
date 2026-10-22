/// SkillLink service provider model.
/// Represents a local service professional available for booking.
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    this.hasPrice = true,
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
  final bool hasPrice;

  static ServiceProvider? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) return null;
    final priceValue = data['price'];
    return ServiceProvider(
      id: snapshot.id,
      name: _string(data, 'fullName', fallback: 'Unnamed provider'),
      profession: _string(data, 'professionalTitle'),
      category: _string(data, 'category'),
      description: _string(data, 'description'),
      location: _string(data, 'location'),
      price: priceValue is num ? priceValue.toDouble() : 0,
      priceUnit: _priceUnit(_string(data, 'pricingUnit')),
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 0,
      imageUrl: _string(data, 'profileImageUrl'),
      isFeatured: data['isFeatured'] == true,
      isVerified: data['isVerified'] == true,
      availability: data['availability'] as String?,
      hasPrice: priceValue is num && priceValue > 0,
    );
  }

  static String _string(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    return value is String ? value : fallback;
  }

  static String _priceUnit(String value) {
    if (value.isEmpty) return '';
    return value.startsWith('/') ? value : ' / $value';
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  String get formattedPrice {
    return hasPrice
        ? 'ETB ${price.toStringAsFixed(0)}$priceUnit'
        : 'Contact for price';
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
    bool? hasPrice,
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
      hasPrice: hasPrice ?? this.hasPrice,
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
