import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_link/models/provider_registration.dart';
import 'package:skill_link/services/provider_registration_service.dart';

void main() {
  test(
    'provider registration defaults to pending and uses unique references',
    () async {
      SharedPreferences.setMockInitialValues({});
      final service = ProviderRegistrationService.instance;
      await service.initialize();

      final first = await service.submit(
        fullName: 'Almaz Worku',
        phone: '0912345678',
        email: '',
        location: 'Bole, Addis Ababa',
        category: 'Tutoring',
        professionalTitle: 'English Tutor',
        experienceYears: 0,
        description: 'Beginner-friendly English lessons for local students.',
        price: null,
        pricingUnit: 'Negotiable',
        availability: 'Weekends only',
      );
      final second = await service.submit(
        fullName: 'Bekele Tadesse',
        phone: '0912345679',
        email: 'bekele@example.com',
        location: 'Lideta, Addis Ababa',
        category: 'Photography',
        professionalTitle: 'Event Photographer',
        experienceYears: 3,
        description:
            'Portrait and event photography for families and businesses.',
        price: 1200,
        pricingUnit: 'Per session',
        availability: 'Available',
      );

      expect(first.status, ProviderRegistrationStatus.pending);
      expect(second.status, ProviderRegistrationStatus.pending);
      expect(first.reference, isNot(second.reference));
      expect(service.registrations, contains(first));
      expect(service.registrations, contains(second));
    },
  );

  test(
    'provider registration reloads from saved state on re-initialize',
    () async {
      SharedPreferences.setMockInitialValues({});
      final service = ProviderRegistrationService.instance;
      await service.initialize();

      await service.submit(
        fullName: 'Old Provider',
        phone: '0910000000',
        email: 'old@example.com',
        location: 'Old Town',
        category: 'Cleaning',
        professionalTitle: 'Cleaner',
        experienceYears: 2,
        description: 'Old listing',
        price: 300,
        pricingUnit: 'Per hour',
        availability: 'Weekdays',
      );

      final stored = jsonEncode([
        ProviderRegistration(
          id: 'pr-reloaded',
          reference: 'PR99999',
          fullName: 'New Provider',
          phone: '0911111111',
          email: 'new@example.com',
          location: 'New Town',
          category: 'Tutoring',
          professionalTitle: 'Tutor',
          experienceYears: 4,
          description: 'Fresh listing',
          price: 400,
          pricingUnit: 'Per session',
          availability: 'Weekends',
          submittedAt: DateTime(2026, 3, 10),
          status: ProviderRegistrationStatus.pending,
        ).toJson(),
      ]);

      SharedPreferences.setMockInitialValues({
        'skilllink_provider_registrations': stored,
      });

      await service.initialize();

      expect(service.registrations, hasLength(1));
      expect(service.registrations.single.fullName, 'New Provider');
      expect(service.registrations.single.reference, 'PR99999');
    },
  );

  test('provider registration survives JSON serialization', () {
    final registration = ProviderRegistration(
      id: 'pr-test',
      reference: 'PR12345',
      fullName: 'Sample Provider',
      phone: '0912345678',
      email: '',
      location: 'Addis Ababa',
      category: 'Cleaning',
      professionalTitle: 'Home Cleaner',
      experienceYears: 2,
      description: 'Reliable home cleaning services.',
      price: 500,
      pricingUnit: 'Per service',
      availability: 'Available',
      submittedAt: DateTime(2026, 10, 21),
      status: ProviderRegistrationStatus.pending,
    );

    final restored = ProviderRegistration.fromJson(registration.toJson());

    expect(restored.id, registration.id);
    expect(restored.reference, registration.reference);
    expect(restored.fullName, registration.fullName);
    expect(restored.price, registration.price);
    expect(restored.status, ProviderRegistrationStatus.pending);
  });
}
