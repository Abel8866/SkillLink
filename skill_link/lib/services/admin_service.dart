import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  AdminService._();

  static final instance = AdminService._();

  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final token = await user.getIdTokenResult(true);
    return token.claims?['admin'] == true;
  }

  Future<List<Map<String, dynamic>>> listRegistrations() async {
    final result = await _functions
        .httpsCallable('listProviderRegistrations')
        .call();
    final data = Map<String, dynamic>.from(result.data as Map);
    return (data['registrations'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> review({
    required String registrationId,
    required String decision,
    String? rejectionReason,
  }) async {
    await _functions.httpsCallable('reviewProviderRegistration').call({
      'registrationId': registrationId,
      'decision': decision,
      'rejectionReason': rejectionReason,
    });
  }
}
