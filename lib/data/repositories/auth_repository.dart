import 'package:firebase_auth/firebase_auth.dart';
import 'package:nova_tasks/data/datasources/remote/firebase_auth_source.dart';
import 'package:nova_tasks/data/models/user_model.dart';

/// High-level API used by viewmodels / UI for auth.
class AuthRepository {
  AuthRepository({FirebaseAuthSource? remote})
    : _remote = remote ?? FirebaseAuthSource();

  final FirebaseAuthSource _remote;

  Stream<UserModel?> get userStream async* {
    await for (final user in _remote.authStateChanges()) {
      if (user == null) {
        yield null;
      } else {
        // For now emit a minimal model; callers can read Firestore if needed.
        yield UserModel(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    }
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _remote.signUpWithEmail(
      name: name,
      email: email,
      password: password,
    );
  }

  Future<UserModel> signIn({required String email, required String password}) {
    return _remote.signInWithEmail(email: email, password: password);
  }
  Future<void> sendPasswordResetEmail(
      String email
      ){
    return _remote.sendPasswordResetEmail(email);
  }


  Future<void> signOut() => _remote.signOut();
}





