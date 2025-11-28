import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nova_tasks/data/models/user_model.dart';

/// Low-level Firebase authentication + user profile access.
class FirebaseAuthSource {
  FirebaseAuthSource({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;

    final now = DateTime.now();
    final userModel = UserModel(
      id: user.uid,
      name: name,
      email: email,
      photoUrl: user.photoURL,
      createdAt: now,
      updatedAt: now,
    );

    await _userCollection().doc(user.uid).set(userModel.toFirestore());
    return userModel;
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;

    final doc = await _userCollection().doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>,
        null,
      );
    }

    final now = DateTime.now();
    final userModel = UserModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? email,
      photoUrl: user.photoURL,
      createdAt: now,
      updatedAt: now,
    );
    await _userCollection().doc(user.uid).set(userModel.toFirestore());
    return userModel;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();

  CollectionReference<Map<String, dynamic>> _userCollection() =>
      _firestore.collection('users');
}


