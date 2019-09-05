import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  static Authentication _authentication;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory Authentication() {
    if (_authentication == null) {
      Firestore.instance.settings(
        persistenceEnabled: true,
        cacheSizeBytes: 104857600,
        sslEnabled: true,
      );
      _authentication = Authentication._internal();
    }
    return _authentication;
  }

  Authentication._internal();

  Future<String> login(String email, String password) async {
    final AuthResult result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user.email;
  }

  Future<String> register(String email, String password) async {
    final AuthResult result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user.email;
  }

  Future<void> logout() async {
    return _auth.signOut();
  }

  Future<String> getLoggedUserEmail() async {
    final FirebaseUser user = await _auth.currentUser();
    if (user == null) return null;
    return user.email;
  }
}
