import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/provider_registration.dart';

class ProviderRegistrationService extends ChangeNotifier {
  ProviderRegistrationService._internal();

  static final ProviderRegistrationService instance =
      ProviderRegistrationService._internal();

  static const _registrationsKey = 'skilllink_provider_registrations';

  final List<ProviderRegistration> _registrations = [];
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  List<ProviderRegistration> get registrations =>
      List.unmodifiable(_registrations);

  Future<void> initialize() async {
    _registrations.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = prefs.getString(_registrationsKey);
      if (encoded != null) {
        final decoded = jsonDecode(encoded);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is! Map) continue;
            try {
              _registrations.add(
                ProviderRegistration.fromJson(Map<String, dynamic>.from(item)),
              );
            } catch (error) {
              debugPrint('Skipping invalid provider registration: $error');
            }
          }
          _registrations.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
        }
      }
    } catch (error) {
      debugPrint('Error loading provider registrations: $error');
    }
    notifyListeners();
  }

  Future<ProviderRegistration> submit({
    required String fullName,
    required String phone,
    required String email,
    required String location,
    required String category,
    required String professionalTitle,
    required int experienceYears,
    required String description,
    required double? price,
    required String pricingUnit,
    required String availability,
    String? profileImageUrl,
    String? ownerUid,
    String? registrationId,
    String? registrationReference,
  }) async {
    final registration = ProviderRegistration(
      id: registrationId ?? newRegistrationId(),
      reference: registrationReference ?? _newReference(),
      fullName: fullName,
      phone: phone,
      email: email,
      location: location,
      category: category,
      professionalTitle: professionalTitle,
      experienceYears: experienceYears,
      description: description,
      price: price,
      pricingUnit: pricingUnit,
      availability: availability,
      submittedAt: DateTime.now(),
      status: ProviderRegistrationStatus.pending,
      profileImageUrl: profileImageUrl,
      ownerUid: ownerUid,
    );

    try {
      if (ownerUid != null) {
        await _firestore
            .collection('providerRegistrations')
            .doc(registration.id)
            .set({
              ...registration.toJson(),
              'createdAt': FieldValue.serverTimestamp(),
              'status': ProviderRegistrationStatus.pending.name,
            });
      }
      _registrations.insert(0, registration);
      await _save();
    } catch (error) {
      _registrations.remove(registration);
      debugPrint('Error saving provider registration: $error');
      rethrow;
    }
    notifyListeners();
    return registration;
  }

  String newRegistrationId() => 'pr-${DateTime.now().microsecondsSinceEpoch}';

  String newRegistrationReference() => _newReference();

  String _newReference() {
    final random = Random.secure();
    String reference;
    do {
      reference = 'PR${random.nextInt(90000) + 10000}';
    } while (_registrations.any((item) => item.reference == reference));
    return reference;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _registrationsKey,
      jsonEncode(_registrations.map((item) => item.toJson()).toList()),
    );
  }
}
