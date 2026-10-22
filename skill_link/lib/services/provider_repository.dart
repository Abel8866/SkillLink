import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/service_provider.dart';

class ProviderRepository {
  ProviderRepository._();

  static final instance = ProviderRepository._();

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('providerRegistrations');

  Query<Map<String, dynamic>> get _publishedQuery => _collection
      .where('status', isEqualTo: 'approved')
      .where('isPublished', isEqualTo: true);

  Stream<List<ServiceProvider>> watchApprovedProviders() {
    debugPrint(
      '[ProviderRepository] Listening to providerRegistrations '
      '(status=approved, isPublished=true).',
    );
    return _publishedQuery
        .snapshots()
        .map((snapshot) {
          debugPrint(
            '[ProviderRepository] Provider query returned '
            '${snapshot.docs.length} document(s).',
          );
          final providers = <ServiceProvider>[];
          for (final document in snapshot.docs) {
            try {
              final provider = ServiceProvider.fromFirestore(document);
              if (provider == null) {
                debugPrint(
                  '[ProviderRepository] Skipping ${document.id}: empty document.',
                );
                continue;
              }
              providers.add(provider);
            } catch (error, stackTrace) {
              debugPrint(
                '[ProviderRepository] Document parsing failed for '
                '${document.id}: $error',
              );
              debugPrintStack(stackTrace: stackTrace);
            }
          }
          return providers;
        })
        .handleError((Object error, StackTrace stackTrace) {
          if (error is FirebaseException) {
            debugPrint(
              '[ProviderRepository] Provider query failed '
              '(code=${error.code}): ${error.message ?? error}',
            );
          } else {
            debugPrint('[ProviderRepository] Provider query failed: $error');
          }
          debugPrintStack(stackTrace: stackTrace);
        });
  }

  Future<ServiceProvider?> getApprovedProvider(String id) async {
    final snapshot = await _collection.doc(id).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null ||
        data['status'] != 'approved' ||
        data['isPublished'] != true) {
      return null;
    }
    return ServiceProvider.fromFirestore(snapshot);
  }
}
