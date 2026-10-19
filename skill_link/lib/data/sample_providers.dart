import 'package:flutter/material.dart';

import '../models/service_provider.dart';

class ProviderCategory {
  const ProviderCategory({required this.name, required this.icon});

  final String name;
  final IconData icon;
}

const List<ProviderCategory> providerCategories = [
  ProviderCategory(name: 'Plumbing', icon: Icons.plumbing),
  ProviderCategory(name: 'Electrician', icon: Icons.electrical_services),
  ProviderCategory(name: 'Tutoring', icon: Icons.school),
  ProviderCategory(name: 'Web Development', icon: Icons.code),
  ProviderCategory(name: 'Graphic Design', icon: Icons.brush),
  ProviderCategory(name: 'Carpentry', icon: Icons.carpenter),
  ProviderCategory(name: 'Photography', icon: Icons.camera_alt),
  ProviderCategory(name: 'Cleaning', icon: Icons.cleaning_services),
];

const List<ServiceProvider> sampleProviders = [
  ServiceProvider(
    id: 'p001',
    name: 'Sarah Mitchell',
    profession: 'Senior Plumber',
    category: 'Plumbing',
    rating: 4.9,
    reviewCount: 148,
    hourlyRate: 45,
    location: 'Downtown',
    imageUrl: 'https://i.pravatar.cc/300?img=47',
    about:
        'Licensed plumber with over 10 years of residential and commercial '
        'experience. Fast response times, transparent pricing, and a '
        'satisfaction guarantee on every job.',
    skills: ['Leak repair', 'Pipe installation', 'Water heaters', 'Drain cleaning'],
    isVerified: true,
    isPremium: true,
  ),
  ServiceProvider(
    id: 'p002',
    name: 'James Okafor',
    profession: 'Certified Electrician',
    category: 'Electrician',
    rating: 4.8,
    reviewCount: 112,
    hourlyRate: 55,
    location: 'Riverside',
    imageUrl: 'https://i.pravatar.cc/300?img=12',
    about:
        'Certified master electrician specializing in home rewiring, panel '
        'upgrades, and smart home installations. Fully insured and bonded.',
    skills: ['Panel upgrades', 'Lighting design', 'Smart home', 'Safety inspections'],
    isVerified: true,
  ),
  ServiceProvider(
    id: 'p003',
    name: 'Emily Chen',
    profession: 'Math & Physics Tutor',
    category: 'Tutoring',
    rating: 5.0,
    reviewCount: 203,
    hourlyRate: 30,
    location: 'University District',
    imageUrl: 'https://i.pravatar.cc/300?img=5',
    about:
        'PhD candidate with 6 years of tutoring experience. I break complex '
        'concepts into intuitive pieces and tailor every session to the '
        'student’s learning style.',
    skills: ['Calculus', 'Physics', 'Exam prep', 'Study planning'],
    isVerified: true,
    isPremium: true,
  ),
  ServiceProvider(
    id: 'p004',
    name: 'Marcus Reid',
    profession: 'Full-Stack Developer',
    category: 'Web Development',
    rating: 4.7,
    reviewCount: 87,
    hourlyRate: 60,
    location: 'Remote',
    imageUrl: 'https://i.pravatar.cc/300?img=33',
    about:
        'Full-stack developer focused on modern web apps with Flutter and '
        'backend integrations. I ship clean, well-tested code on tight '
        'deadlines.',
    skills: ['Flutter', 'REST APIs', 'Firebase', 'CI/CD'],
    isVerified: true,
  ),
  ServiceProvider(
    id: 'p005',
    name: 'Ava Thompson',
    profession: 'Graphic Designer',
    category: 'Graphic Design',
    rating: 4.6,
    reviewCount: 95,
    hourlyRate: 35,
    location: 'Harbor Side',
    imageUrl: 'https://i.pravatar.cc/300?img=44',
    about:
        'Brand-focused designer helping small businesses stand out with '
        'memorable logos, packaging, and social media visuals.',
    skills: ['Logo design', 'Brand identity', 'Illustrations', 'Social media kits'],
    isVerified: false,
  ),
  ServiceProvider(
    id: 'p006',
    name: 'Daniel Brooks',
    profession: 'Master Carpenter',
    category: 'Carpentry',
    rating: 4.9,
    reviewCount: 76,
    hourlyRate: 40,
    location: 'Westgate',
    imageUrl: 'https://i.pravatar.cc/300?img=15',
    about:
        'Third-generation carpenter crafting custom furniture, shelving, and '
        'precision trim work. Every project is finished by hand.',
    skills: ['Custom furniture', 'Deck building', 'Trim & molding', 'Repairs'],
    isVerified: true,
  ),
  ServiceProvider(
    id: 'p007',
    name: 'Sofia Ramirez',
    profession: 'Event Photographer',
    category: 'Photography',
    rating: 4.8,
    reviewCount: 134,
    hourlyRate: 50,
    location: 'Downtown',
    imageUrl: 'https://i.pravatar.cc/300?img=45',
    about:
        'Story-driven photographer covering weddings, corporate events, and '
        'portraits. Galleries delivered within 48 hours.',
    skills: ['Portraits', 'Events', 'Editing', 'Lifestyle shoots'],
    isVerified: true,
    isPremium: true,
  ),
  ServiceProvider(
    id: 'p008',
    name: 'Liam Foster',
    profession: 'Home Cleaning Pro',
    category: 'Cleaning',
    rating: 4.5,
    reviewCount: 210,
    hourlyRate: 25,
    location: 'Midtown',
    imageUrl: 'https://i.pravatar.cc/300?img=59',
    about:
        'Detail-oriented home cleaner with eco-friendly products and '
        'flexible scheduling, including same-day service.',
    skills: ['Deep cleaning', 'Move-out cleaning', 'Eco products', 'Same-day service'],
    isVerified: false,
  ),
  ServiceProvider(
    id: 'p009',
    name: 'Nadia Petrova',
    profession: 'Math & Science Tutor',
    category: 'Tutoring',
    rating: 4.9,
    reviewCount: 61,
    hourlyRate: 28,
    location: 'North Hills',
    imageUrl: 'https://i.pravatar.cc/300?img=16',
    about:
        'Former high school teacher tutoring chemistry, biology, and math. '
        'I focus on building confidence and long-term understanding.',
    skills: ['Chemistry', 'Biology', 'Algebra', 'Test prep'],
    isVerified: true,
  ),
  ServiceProvider(
    id: 'p010',
    name: 'Ethan Cole',
    profession: 'Emergency Plumber',
    category: 'Plumbing',
    rating: 4.6,
    reviewCount: 99,
    hourlyRate: 50,
    location: 'Eastport',
    imageUrl: 'https://i.pravatar.cc/300?img=53',
    about:
        '24/7 emergency plumber specializing in burst pipes and urgent '
        'repairs. On call nights and weekends with no after-hours surcharge.',
    skills: ['Emergency repairs', 'Burst pipes', 'Bathroom fitting', 'Inspections'],
    isVerified: true,
  ),
];
