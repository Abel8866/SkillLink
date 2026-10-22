import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileService {
  UserProfileService._();

  static final UserProfileService instance = UserProfileService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> ensureProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    final reference = _firestore.collection('users').doc(uid);
    final snapshot = await reference.get();
    if (!snapshot.exists) {
      await createProfile(uid: uid, name: name, email: email);
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<void> updateProfileImage({
    required String uid,
    required String imageUrl,
  }) {
    return _firestore.collection('users').doc(uid).update({
      'profileImageUrl': imageUrl,
    });
  }
}
