import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthManager {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  AuthManager(this._auth, this._googleSignIn);

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    // etc....
  }

  GoogleSignInAccount? get googleAccount {
    return _googleSignIn.currentUser;
  }
}