import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInHelper {
  // Paste your Google Web Client ID here (from Google Cloud Console -> Credentials -> OAuth Web Application)
  // This is required on Android to retrieve the idToken.
  static const String? _webClientId = "308069649363-5qn9ole74gehrr242rnhi9lsvduhrt87.apps.googleusercontent.com";

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: _webClientId,
  );

  static Future<String?> signIn() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        
        // ── Sign in to Firebase using Google Credentials ────────────────
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: auth.accessToken,
          idToken: auth.idToken,
        );

        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final User? firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          // Retrieve the Firebase ID Token (iss: securetoken.google.com) instead of raw Google ID Token!
          final String? firebaseIdToken = await firebaseUser.getIdToken();
          return firebaseIdToken;
        }
      }
    } catch (e) {
      // Re-throw to handle error or display it in user presentation snackbar
      rethrow;
    }
    return null;
  }
}
