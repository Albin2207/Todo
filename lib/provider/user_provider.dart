import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_firebase/controllers/auth_service.dart';
import 'package:todo_app_firebase/controllers/database_service.dart';
import 'package:todo_app_firebase/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  // User data fields
  String name = "";
  String email = "";
  String? username;
  String? bio;
  String? profileImageUrl;
  Map<String, dynamic>? preferences;

  bool isLoggedIn = false;
  bool isLoading = true;

  UserProvider() {
    // Empty constructor - initializeUser will be called from main.dart
  }

  Future<void> initializeUser() async {
    // Set up auth state listener
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        isLoggedIn = true;
        _setupUserListener(user.uid);
      } else {
        isLoggedIn = false;
        _clearUserData();
      }
      notifyListeners();
    });
    
    // Check current user immediately
    final user = _auth.currentUser;
    if (user != null) {
      isLoggedIn = true;
      _setupUserListener(user.uid);
    } else {
      isLoading = false;
      notifyListeners();
    }
  }

  void _setupUserListener(String uid) {
    // Cancel any existing subscription
    _userSubscription?.cancel();
    
    // Setup real-time listener for user data
    _userSubscription = FirebaseFirestore.instance
        .collection("todo_users") // Changed from shop_users to todo_users
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        _updateUserDataFromMap(userData);
      } else {
        // Handle case where user auth exists but Firestore data doesn't
        debugPrint("User document does not exist in Firestore for UID: $uid");
        // Use display name from Firebase Auth as fallback
        name = _auth.currentUser?.displayName ?? "";
        email = _auth.currentUser?.email ?? "";
      }
      isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error in user data listener: $error");
      isLoading = false;
      notifyListeners();
    });
  }

  void _updateUserDataFromMap(Map<String, dynamic> userData) {
    try {
      final UserModel data = UserModel.fromJson(userData);
      name = data.name;
      email = data.email;
      username = data.username;
      bio = data.bio;
      profileImageUrl = data.profileImageUrl;
      preferences = data.preferences;
    } catch (e) {
      debugPrint("Error parsing user data: $e");
    }
  }

  void _clearUserData() {
    name = "";
    email = "";
    username = null;
    bio = null;
    profileImageUrl = null;
    preferences = null;
    isLoading = false;
  }

  Future<void> refreshUserData() async {
    try {
      if (_auth.currentUser == null) return;
      
      isLoading = true;
      notifyListeners();
      
      Map<String, dynamic>? userData = await DbService().readUserData();
      if (userData != null) {
        _updateUserDataFromMap(userData);
      }
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error refreshing user data: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? username,
    String? bio,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
  }) async {
    final data = {
      "name": name,
      "email": email,
      if (username != null) "username": username,
      if (bio != null) "bio": bio,
      if (profileImageUrl != null) "profileImageUrl": profileImageUrl,
      if (preferences != null) "preferences": preferences,
    };
    
    await DbService().updateUserData(extraData: data);
    // No need to manually update local data since the Firestore listener will handle it
  }

  // Method to update specific user preferences
  Future<void> updatePreferences(Map<String, dynamic> newPreferences) async {
    // Merge new preferences with existing ones
    final updatedPreferences = {...(preferences ?? {}), ...newPreferences};
    
    final data = {
      "preferences": updatedPreferences,
    };
    
    await DbService().updateUserData(extraData: data);
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      // Auth state listener will handle clearing user data
    } catch (e) {
      debugPrint("Error during logout: $e");
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}