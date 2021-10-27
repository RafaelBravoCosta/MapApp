import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projeto/helpers/firebase_helper.dart';

// Use with ChangeNotifier Mixin to allow us to use notifyListeners()
// This will re-render all listeners who are listening with context.watch<AuthenticationService>()
class AuthenticationService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  String currentUserUid;

  AuthenticationService(this._firebaseAuth);

  FirebaseHelper _firebaseHelper = new FirebaseHelper();

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    // Use GoogleSignInAccount.disconnect() before signing out to revoke the previous authentication
    // So that it revokes the previous signed in account and does not automatically select it again on sign in with google
    final GoogleSignIn googleSignIn = GoogleSignIn();

    await _firebaseAuth.signOut();
    await googleSignIn.disconnect();
  }

  Future<String> signIn({String email, String password}) async {
    try {
      await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) => {currentUserUid = value.user.uid});
      notifyListeners();
      FirebaseHelper.showToast('Logged in successfully...');

      return "Signed in";
    } on FirebaseAuthException catch (e) {
      FirebaseHelper.showToast('Error: ${e.message}');
      return e.message;
    }
  }

  Future<String> signUp({String email, String password}) async {
    try {
      await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                currentUserUid = value.user.uid,
              });
      _firebaseHelper.addUser(email, currentUserUid);
      notifyListeners();
      FirebaseHelper.showToast('Signed up successfully...');
      return "Signed up";
    } on FirebaseAuthException catch (e) {
      FirebaseHelper.showToast('Error: ${e.message}');
      return e.message;
    }
  }

  // Function to reset user password
  Future<String> resetPassword(String email) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.sendPasswordResetEmail(
        email: email,
      );
      // if the sendPasswordResetEmail succeeded successfully, return 'ok' so that we know that everything went well
      return 'ok';
    } on FirebaseAuthException catch (error) {
      // if there is an exception, this means that there is an error
      // handle the error and show an appropriate message to the user
      print(error.code);
      print(error.message);
      if (error.code == 'user-not-found') {
        FirebaseHelper.showToast('No user found for that email');
        return 'No user found for that email';
      } else if (error.code == 'invalid-email') {
        FirebaseHelper.showToast('Invalid email entered');
        return 'Invalid email entered';
      }
      FirebaseHelper.showToast(error.message);
      return error.message;
    }
  }

  // Changed function from static to non-static to allow it to call notifyListeners()
  // so that the AuthenticationWrapper widget re-renders
  Future<User> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here

        } else if (e.code == 'invalid-credential') {
          // handle the error here
        }
        FirebaseHelper.showToast('Error: ${e.message}');
      } catch (e) {
        FirebaseHelper.showToast('Error: $e');
        // handle the error here
      }
    }

    return user;
  }
}
