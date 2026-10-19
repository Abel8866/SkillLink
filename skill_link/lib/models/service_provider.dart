import 'package:flutter/material.dart';

@immutable
class ServiceProvider {
  const ServiceProvider({
    required this.id,
    required this.name,
    required this.profession,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.hourlyRate,
    required this.location,
    required this.imageUrl,
    required this.about,
    required this.skills,
    required this.isVerified,
    this.isPremium = false,
  });

  final String id;
  final String name;
  final String profession;
  final String category;
  final double rating;
  final int reviewCount;
  final double hourlyRate;
  final String location;
  final String imageUrl;
  final String about;
  final List<String> skills;
  final bool isVerified;
  final bool isPremium;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}
