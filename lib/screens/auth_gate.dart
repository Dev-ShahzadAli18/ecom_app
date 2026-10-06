import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/screens/navigation.dart';
import 'package:ecom_app/screens/welcome_screen.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_drwaer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _startupUserId;
  Future<Map<String, dynamic>>? _startupFuture;

  Future<Map<String, dynamic>> _fetchUserData(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final String name = data["name"] ?? user.displayName ?? "User";
        final String email = data["email"] ?? user.email ?? "";
        final storedRole = (data["role"] ?? "user")
            .toString()
            .trim()
            .toLowerCase();
        final String role = storedRole == "admin" ? "admin" : "user";

        UserData.name = name;
        UserData.email = email;
        UserData.role = role;

        return {"role": role, "name": name, "email": email};
      }
    } catch (e) {
      debugPrint("Error fetching user data in AuthGate: $e");
    }
    final String fallbackName = user.displayName ?? "User";
    final String fallbackEmail = user.email ?? "";
    String fallbackRole = "user";

    UserData.name = fallbackName;
    UserData.email = fallbackEmail;
    UserData.role = fallbackRole;

    return {"role": fallbackRole, "name": fallbackName, "email": fallbackEmail};
  }

  Future<Map<String, dynamic>> _prepareAuthenticatedHome(User user) async {
    await Future<void>.delayed(Duration(milliseconds: 1100));
    return _fetchUserData(user);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _buildSplashScreen(context);
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          final user = authSnapshot.data!;
          if (_startupUserId != user.uid) {
            _startupUserId = user.uid;
            _startupFuture = _prepareAuthenticatedHome(user);
          }

          return FutureBuilder<Map<String, dynamic>>(
            future: _startupFuture,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return _buildSplashScreen(context);
              }

              final String role = userSnapshot.data?["role"] ?? "user";
              return MainNavigation(role: role);
            },
          );
        }

        _startupUserId = null;
        _startupFuture = null;
        return WelcomePage();
      },
    );
  }

  Widget _buildSplashScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 17, 17, 15),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1),
              duration: Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: Container(
                  height: 86,
                  width: 86,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.22),
                        blurRadius: 30,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 44,
                    color: Color(0xff11110F),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "GEMSTORE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Discover your style",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.68),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 42),
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
