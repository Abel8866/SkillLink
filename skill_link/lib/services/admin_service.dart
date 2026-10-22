import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';

class AdminService {
  AdminService._();

  static final instance = AdminService._();

  static const _region = 'us-central1';
  static const _listFunctionName = 'listProviderRegistrations';
  static const _reviewFunctionName = 'reviewProviderRegistration';

  FirebaseFunctions get _functions =>
      FirebaseFunctions.instanceFor(region: _region);

  Future<bool> isAdmin() async {
    return AuthService.instance.refreshAdminClaim();
  }

  Future<List<Map<String, dynamic>>> listRegistrations() async {
    final user = AuthService.instance.currentUser;
    final isAdmin = await AuthService.instance.refreshAdminClaim();
    _logRequest(_listFunctionName, user?.uid, isAdmin);
    try {
      final result = await _functions.httpsCallable(_listFunctionName).call();
      final data = Map<String, dynamic>.from(result.data as Map);
      final registrations = data['registrations'];
      if (registrations is! List) {
        throw const FormatException(
          'The registration list response was invalid.',
        );
      }
      return registrations
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on FirebaseFunctionsException catch (error, stackTrace) {
      debugPrint(
        '[AdminService] $_listFunctionName failed '
        '(region=$_region, code=${error.code}): '
        '${error.message ?? error}',
      );
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('[AdminService] $_listFunctionName failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> review({
    required String registrationId,
    required String decision,
    String? rejectionReason,
  }) async {
    final user = AuthService.instance.currentUser;
    final isAdmin = await AuthService.instance.refreshAdminClaim();
    _logRequest(_reviewFunctionName, user?.uid, isAdmin);
    try {
      await _functions.httpsCallable(_reviewFunctionName).call({
        'registrationId': registrationId,
        'decision': decision,
        'rejectionReason': rejectionReason,
      });
    } on FirebaseFunctionsException catch (error, stackTrace) {
      debugPrint(
        '[AdminService] $_reviewFunctionName failed '
        '(region=$_region, code=${error.code}): '
        '${error.message ?? error}',
      );
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  void _logRequest(String functionName, String? uid, bool isAdmin) {
    debugPrint(
      '[AdminService] Calling $functionName '
      '(region=$_region, project=${Firebase.app().options.projectId}, '
      'uid=${uid ?? '<signed-out>'}, admin=$isAdmin)',
    );
  }
}
