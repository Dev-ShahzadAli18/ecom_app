import 'package:ecom_app/screens/navigation.dart';
import 'package:ecom_app/screens/welcome_screen.dart';
import 'package:ecom_app/services/auth_service.dart';
import 'package:ecom_app/services/user_service.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_drwaer.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  String? _startupUserId;
  Future<Map<String, dynamic>>? _startupFuture;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _buildSplashScreen(context);
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          final user = authSnapshot.data!;
          if (_startupUserId != user.uid) {
            _startupUserId = user.uid;
            _startupFuture = _userService.prepareUserSession(user);
          }

          return FutureBuilder<Map<String, dynamic>>(
            future: _startupFuture,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return _buildSplashScreen(context);
              }

              final profile = userSnapshot.data ?? {};
              UserData.name = (profile["name"] ?? "").toString();
              UserData.email = (profile["email"] ?? "").toString();
              UserData.role = (profile["role"] ?? "user").toString();
              return MainNavigation(role: UserData.role);
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
