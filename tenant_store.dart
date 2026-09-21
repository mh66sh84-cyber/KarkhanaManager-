import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// One owner account = one business. Never use the business name as an ID.
/// Instantiate after Firebase initialization. Dispose all listeners on logout.
class TenantStore {
  TenantStore({required FirebaseAuth auth, required FirebaseFirestore firestore})
      : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get business {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Sign in before accessing business data.');
    }
    return _firestore.collection('businesses').doc(user.uid);
  }
}
