import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/screens/login_screen.dart';
import 'package:ecom_app/screens/navigation.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_drwaer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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
    const String fallbackRole = "user";

    UserData.name = fallbackName;
    UserData.email = fallbackEmail;
    UserData.role = fallbackRole;

    return {"role": fallbackRole, "name": fallbackName, "email": fallbackEmail};
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // While waiting for initial Firebase Auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(context);
        }

        // If user is already logged in
        if (authSnapshot.hasData && authSnapshot.data != null) {
          final user = authSnapshot.data!;

          return FutureBuilder<Map<String, dynamic>>(
            future: _fetchUserData(user),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen(context);
              }

              final String role = userSnapshot.data?["role"] ?? "user";
              return MainNavigation(role: role);
            },
          );
        }

        // If user is not logged in -> navigate to LoginPage
        return LoginPage();
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double logoSize = (screenWidth * 0.18).clamp(60.0, 90.0);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: logoSize,
              width: logoSize,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 38,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "GemStore",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Discover your style",
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),
            const SizedBox(height: 36),
            SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
