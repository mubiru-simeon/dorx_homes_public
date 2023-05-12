import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'services.dart';

class AuthProvider extends InheritedWidget {
  final AuthService auth;
  AuthProvider({
    Key key,
    Widget child,
    this.auth,
  }) : super(key: key, child: child);

  @override
  // ignore: avoid_renaming_method_parameters
  bool updateShouldNotify(InheritedWidget oldWiddget) {
    return true;
  }

  static AuthProvider of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<AuthProvider>());
}

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Stream<User> get onAuthStateChanged => _firebaseAuth.authStateChanges();

//GET USER
  User getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  reloadAccount(BuildContext context) {
    _firebaseAuth.currentUser?.reload();
  }

  startVerifyingEmail() {
    _firebaseAuth.currentUser.sendEmailVerification();
  }

  changeEmailThenVerify(String email) {
    _firebaseAuth.currentUser.verifyBeforeUpdateEmail(
      email,
    );
  }

  bool isSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // GET UID
  getCurrentUID() {
    return _firebaseAuth.currentUser.uid;
  }

  getDisplayPic() {
    return _firebaseAuth.currentUser.photoURL;
  }

  // Email & Password Sign Up
  Future<String> createUserWithEmailAndPassword(
      String email, String password, String username) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Update the username
    await updateUserName(username, authResult.user);
    return authResult.user.uid;
  }

  Future updateUserName(String name, User currentUser) async {
    currentUser.updateDisplayName(name.trim());
    await currentUser.reload();
  }

  // Email & Password Log In
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    ))
        .user
        .uid;
  }

  Future<void> updateProfPic(String profPic) {
    return _firebaseAuth.currentUser.updatePhotoURL(profPic);
  }

  // Log Out
  signOut() {
    if (_firebaseAuth.currentUser != null) {
      StorageServices().updateLastLogout(
        _firebaseAuth.currentUser.uid,
      );

      return _firebaseAuth.signOut();
    }
  }

  // Reset Password
  Future sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  // Create Anonymous User
  Future signInAnonymously() {
    return _firebaseAuth.signInAnonymously();
  }

  Future convertUserWithEmail(
      String email, String password, String username) async {
    final currentUser = _firebaseAuth.currentUser;

    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    await currentUser.linkWithCredential(credential);
    await updateUserName(username, currentUser);
  }
}
