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
