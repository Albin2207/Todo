import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app_firebase/controllers/database_service.dart';



class AuthService {
  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Creating an account using email and password
  Future<String> createAccountWithEmail(String name, String email, String password) async {
    try {
      // Create the user with email and password
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      
      //update user display name in firebase auth
      await userCredential.user?.updateDisplayName(name);
      
      //save the details to firebase for proper display and updation of user
      await DbService().saveUserData(name: name, email: email);
      
      // Send email verification
      await userCredential.user?.sendEmailVerification();

      return "Account created. Please verify your email.";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  // Login using email and password
  Future<String> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // Check if the user's email is verified
      if (userCredential.user?.emailVerified ?? false) {
        // Ensure user data exists in Firestore
        var userData = await DbService().readUserData();
        if (userData == null) {
          // Create user data if it doesn't exist
          String name = userCredential.user?.displayName ?? "User";
          await DbService().saveUserData(name: name, email: email);
        }
        return "Login Successful";
      } else {
        return "Please verify your email before logging in.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  // Logout
  Future<void> logout() async {
    // Clear any local cart data or other user-specific state here
    // ...
    
    // Sign out from Firebase
    await _firebaseAuth.signOut();
  }

  // Reset password
  Future<String> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return "Mail Sent";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  // Check whether the user is signed in or not
  Future<bool> isLoggedIn() async {
    var user = _firebaseAuth.currentUser;
    return user != null;
  }

  // Resend verification email if the email is not verified
  Future<void> resendVerificationEmail() async {
    var user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print("Verification mail has been resent");
    }
  }

  //google sign in
  // Future<dynamic> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

  //     //user cancels sign in
  //     if (gUser == null) return null;

  //     //obtain auth details from request
  //     final GoogleSignInAuthentication gAuth = await gUser.authentication;

  //     //create a new credential for user
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: gAuth.accessToken,
  //       idToken: gAuth.idToken,
  //     );

  //     //sign in
  //     UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
  //     // Check if this is a new user (first time sign in) and create Firestore user data
  //     if (userCredential.additionalUserInfo?.isNewUser == true) {
  //       String name = userCredential.user?.displayName ?? "User";
  //       String email = userCredential.user?.email ?? "";
  //       await DbService().saveUserData(name: name, email: email);
  //     }
      
  //     return userCredential;
  //   } catch (e) {
  //     print("Error during Google sign in: $e");
  //     return e.toString();
  //   }
  // }
}