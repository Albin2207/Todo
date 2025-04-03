import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_firebase/widgets/bottom_navigationbar.dart';
import 'package:todo_app_firebase/view/authentication/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the snapshot has a user
        if (snapshot.hasData && snapshot.data != null) {
          // Check if email is verified
          if (snapshot.data!.emailVerified) {
            // User is logged in and email is verified, redirect to MainPage
            return const MainPage();
          } else {
            // Email is not verified, redirect to login with a message
            // You could show a snackbar here or use a dialog
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please verify your email before logging in."),
                  backgroundColor: Colors.amber,
                ),
              );
            });
            return const LoginPage();
          }
        } else {
          // User is not logged in, redirect to login
          return const LoginPage();
        }
      },
    );
  }
}