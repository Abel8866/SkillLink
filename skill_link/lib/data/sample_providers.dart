/// SkillLink sample data for Ethiopian market (Addis Ababa).
/// Contains service categories and demonstration providers.
library;

import 'package:flutter/material.dart';

import '../models/service_provider.dart';

class ProviderCategory {
  const ProviderCategory({
    required this.name,
    required this.icon,
    this.description,
  });

  final String name;
  final IconData icon;
  final String? description;
}

const List<ProviderCategory> providerCategories = [
  ProviderCategory(name: 'All', icon: Icons.apps, description: 'All services'),
  ProviderCategory(
    name: 'Tutoring',
    icon: Icons.school_rounded,
    description: 'Academic tutoring & test prep',
  ),
  ProviderCategory(
    name: 'Photography',
    icon: Icons.camera_alt_rounded,
    description: 'Events, portraits, commercial',
  ),
  ProviderCategory(
    name: 'Electrical',
    icon: Icons.electrical_services_rounded,
    description: 'Wiring, repairs, installations',
  ),
  ProviderCategory(
    name: 'Plumbing',
    icon: Icons.plumbing_rounded,
    description: 'Pipes, leaks, installations',
  ),
  ProviderCategory(
    name: 'Graphic Design',
    icon: Icons.design_services_rounded,
    description: 'Logos, branding, marketing',
  ),
  ProviderCategory(
    name: 'Cleaning',
    icon: Icons.cleaning_services_rounded,
    description: 'Home & office cleaning',
  ),
];

// Category names for filtering (excluding 'All')
const List<String> serviceCategoryNames = [
  'Tutoring',
  'Photography',
  'Electrical',
  'Plumbing',
  'Graphic Design',
  'Cleaning',
];

const List<ServiceProvider> sampleProviders = [
  ServiceProvider(
    id: 'p001',
    name: 'Hana Tesfaye',
    profession: 'Mathematics Tutor',
    category: 'Tutoring',
    description:
        'Experienced mathematics tutor specializing in high school and university-level calculus, algebra, and statistics. I help students build strong foundations and confidence in math through personalized lesson plans and patient guidance.',
    location: 'Bole, Addis Ababa',
    price: 350,
    priceUnit: '/hour',
    rating: 4.8,
    reviewCount: 42,
    experienceYears: 5,
    imageUrl: 'https://i.pravatar.cc/300?img=47',
    isFeatured: true,
    isVerified: true,
    availability: 'Mon-Sat 9AM-7PM',
  ),
  ServiceProvider(
    id: 'p002',
    name: 'Dawit Bekele',
    profession: 'Professional Photographer',
    category: 'Photography',
    description:
        'Award-winning photographer with 8 years of experience capturing weddings, corporate events, portraits, and commercial projects. I bring a creative eye and professional equipment to every session, delivering high-quality images within 48 hours.',
    location: 'Kazanchis, Addis Ababa',
    price: 2000,
    priceUnit: '/session',
    rating: 4.7,
    reviewCount: 89,
    experienceYears: 8,
    imageUrl: 'https://i.pravatar.cc/300?img=12',
    isFeatured: true,
    isVerified: true,
    availability: 'Daily 8AM-8PM (by appointment)',
  ),
  ServiceProvider(
    id: 'p003',
    name: 'Samuel Girma',
    profession: 'Certified Electrician',
    category: 'Electrical',
    description:
        'Licensed electrician with 10+ years of experience in residential and commercial electrical systems. Specializing in wiring, panel upgrades, lighting design, and safety inspections. Fully insured and committed to quality workmanship.',
    location: 'Sar Bet, Addis Ababa',
    price: 500,
    priceUnit: '/service',
    rating: 4.6,
    reviewCount: 67,
    experienceYears: 10,
    imageUrl: 'https://i.pravatar.cc/300?img=33',
    isFeatured: false,
    isVerified: true,
    availability: 'Mon-Sat 8AM-6PM, Emergency 24/7',
  ),
  ServiceProvider(
    id: 'p004',
    name: 'Meron Alemu',
    profession: 'Graphic Designer',
    category: 'Graphic Design',
    description:
        'Creative graphic designer helping businesses build strong visual identities. Expertise in logo design, brand guidelines, marketing materials, and social media content. I work closely with clients to bring their vision to life.',
    location: 'Addis Ababa',
    price: 600,
    priceUnit: '/project',
    rating: 4.9,
    reviewCount: 34,
    experienceYears: 4,
    imageUrl: 'https://i.pravatar.cc/300?img=44',
    isFeatured: true,
    isVerified: true,
    availability: 'Mon-Fri 9AM-6PM',
  ),
  ServiceProvider(
    id: 'p005',
    name: 'Abel Worku',
    profession: 'Plumbing Specialist',
    category: 'Plumbing',
    description:
        'Professional plumber with expertise in residential and commercial plumbing systems. From leak repairs and drain cleaning to new installations and bathroom renovations. Fast response, transparent pricing, and guaranteed work.',
    location: 'Addis Ababa',
    price: 450,
    priceUnit: '/service',
    rating: 4.5,
    reviewCount: 53,
    experienceYears: 7,
    imageUrl: 'https://i.pravatar.cc/300?img=15',
    isFeatured: false,
    isVerified: true,
    availability: 'Mon-Sat 8AM-7PM, Emergency 24/7',
  ),
  ServiceProvider(
    id: 'p006',
    name: 'Bethlehem Tadesse',
    profession: 'English Tutor',
    category: 'Tutoring',
    description:
        'Certified English language tutor helping students improve their speaking, writing, and comprehension skills. Specializes in IELTS/TOEFL preparation, business English, and academic writing. Patient, encouraging, and results-oriented.',
    location: 'Addis Ababa',
    price: 300,
    priceUnit: '/hour',
    rating: 4.7,
    reviewCount: 28,
    experienceYears: 3,
    imageUrl: 'https://i.pravatar.cc/300?img=5',
    isFeatured: true,
    isVerified: true,
    availability: 'Mon-Sun 10AM-8PM',
  ),
  ServiceProvider(
    id: 'p007',
    name: 'Yared Kebede',
    profession: 'Physics & Chemistry Tutor',
    category: 'Tutoring',
    description:
        'University-level physics and chemistry tutor with a master\'s degree in Applied Physics. I simplify complex concepts and provide structured problem-solving approaches for high school and undergraduate students.',
    location: 'Piazza, Addis Ababa',
    price: 400,
    priceUnit: '/hour',
    rating: 4.9,
    reviewCount: 31,
    experienceYears: 6,
    imageUrl: 'https://i.pravatar.cc/300?img=59',
    isFeatured: false,
    isVerified: true,
    availability: 'Tue-Sun 2PM-9PM',
  ),
  ServiceProvider(
    id: 'p008',
    name: 'Selamawit Haile',
    profession: 'Event Photographer',
    category: 'Photography',
    description:
        'Specialized in cultural events, weddings, and corporate photography. I capture authentic moments with a documentary style. Packages include edited digital gallery, prints, and optional album design.',
    location: 'Bole, Addis Ababa',
    price: 2500,
    priceUnit: '/session',
    rating: 4.6,
    reviewCount: 45,
    experienceYears: 5,
    imageUrl: 'https://i.pravatar.cc/300?img=45',
    isFeatured: false,
    isVerified: true,
    availability: 'By appointment only',
  ),
  ServiceProvider(
    id: 'p009',
    name: 'Tesfaye Lemma',
    profession: 'Senior Electrician',
    category: 'Electrical',
    description:
        'Master electrician with 15 years of experience in industrial and residential electrical work. Expert in solar installations, backup power systems, and smart home automation. Safety-first approach with all certifications current.',
    location: 'Kirkos, Addis Ababa',
    price: 600,
    priceUnit: '/service',
    rating: 4.8,
    reviewCount: 72,
    experienceYears: 15,
    imageUrl: 'https://i.pravatar.cc/300?img=16',
    isFeatured: true,
    isVerified: true,
    availability: 'Mon-Sat 7AM-5PM',
  ),
  ServiceProvider(
    id: 'p010',
    name: 'Rahel Mohammed',
    profession: 'Plumbing & Drainage Expert',
    category: 'Plumbing',
    description:
        'Specialized in drainage systems, water supply, and bathroom/kitchen plumbing renovations. Uses modern diagnostic equipment for accurate problem detection. Offers maintenance plans for commercial properties.',
    location: 'Lideta, Addis Ababa',
    price: 550,
    priceUnit: '/service',
    rating: 4.7,
    reviewCount: 38,
    experienceYears: 9,
    imageUrl: 'https://i.pravatar.cc/300?img=46',
    isFeatured: false,
    isVerified: true,
    availability: 'Mon-Fri 8AM-6PM',
  ),
  ServiceProvider(
    id: 'p011',
    name: 'Mekdes Assefa',
    profession: 'Brand & UI Designer',
    category: 'Graphic Design',
    description:
        'Product designer focused on brand identity, UI/UX design, and digital products. Worked with startups and established businesses across Ethiopia. Delivers design systems, prototypes, and production-ready assets.',
    location: 'Kazanchis, Addis Ababa',
    price: 800,
    priceUnit: '/project',
    rating: 4.8,
    reviewCount: 22,
    experienceYears: 4,
    imageUrl: 'https://i.pravatar.cc/300?img=53',
    isFeatured: false,
    isVerified: true,
    availability: 'Mon-Fri 9AM-5PM',
  ),
  ServiceProvider(
    id: 'p012',
    name: 'Daniel Getachew',
    profession: 'Home Cleaning Specialist',
    category: 'Cleaning',
    description:
        'Professional home cleaning service with eco-friendly products and attention to detail. Services include deep cleaning, move-in/move-out cleaning, and regular maintenance. Flexible scheduling and satisfaction guaranteed.',
    location: 'Bole, Addis Ababa',
    price: 400,
    priceUnit: '/service',
    rating: 4.6,
    reviewCount: 61,
    experienceYears: 3,
    imageUrl: 'https://i.pravatar.cc/300?img=52',
    isFeatured: false,
    isVerified: false,
    availability: 'Daily 7AM-7PM',
  ),
];

/// Helper to get providers by category
List<ServiceProvider> getProvidersByCategory(String category) {
  if (category == 'All') return sampleProviders;
  return sampleProviders.where((p) => p.category == category).toList();
}

/// Helper to get featured providers
List<ServiceProvider> getFeaturedProviders() {
  return sampleProviders.where((p) => p.isFeatured).toList();
}

/// Helper to search providers
List<ServiceProvider> searchProviders(String query) {
  final q = query.toLowerCase().trim();
  if (q.isEmpty) return sampleProviders;
  return sampleProviders.where((p) {
    return p.name.toLowerCase().contains(q) ||
        p.profession.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q) ||
        p.location.toLowerCase().contains(q);
  }).toList();
}
