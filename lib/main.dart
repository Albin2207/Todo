import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_firebase/firebase_options.dart';
import 'package:todo_app_firebase/provider/user_provider.dart';
import 'package:todo_app_firebase/view/authentication/login_screen.dart';
import 'package:todo_app_firebase/view/authentication/sigup_screen.dart';
import 'package:todo_app_firebase/widgets/auth_wrapper.dart';
import 'package:todo_app_firebase/widgets/bottom_navigationbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..initializeUser()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0xFF1E6F9F),
          scaffoldBackgroundColor: Color(0xFF1A1A1A),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1E6F9F),
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF1E6F9F),
            foregroundColor: Colors.white,
          ),
        ),
        title: 'Todo App',

        home: const AuthWrapper(),

        routes: {
          "/home": (context) => const MainPage(),
          "/login": (context) => const LoginPage(),
          "/signup": (context) => const SignupPage(),
        },
      ),
    );
  }
}
