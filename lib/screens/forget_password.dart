import 'package:ecom_app/screens/verification_screen.dart';
import 'package:ecom_app/services/auth_service.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.sendPasswordResetEmail(email: email);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset link sent to $email")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationCode(),
        ),
      );
    } on AuthServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send reset email: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double horizontalPadding = (screenWidth * 0.055).clamp(16.0, 24.0);

    Color lineColor = AppColors.isDark ? Color(0xff3A3A3A) : Color(0xffE5E5E5);
    Color arrowColor = AppColors.isDark ? Color(0xffB0B0B0) : Color(0xff555555);
    Color descColor = AppColors.isDark ? Color(0xffB0B0B0) : Color(0xff4D4D4D);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),

                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: lineColor),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 14,
                            color: arrowColor,
                          ),
                        ),
                      ),

                      SizedBox(height: 35),

                      Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontSize: (screenWidth * 0.055).clamp(20.0, 24.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Enter your email associated with your account\n"
                        "and we'll send you a password reset link to\n"
                        "reset your password.",
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: descColor,
                        ),
                      ),

                      SizedBox(height: 35),

                      CustomTextField(
                        controller: emailController,
                        hintText: "Enter your email",
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),

                      Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: CustomButton(
                          text: isLoading ? "Sending..." : "Continue",
                          onTap: isLoading ? null : _handlePasswordReset,
                        ),
                      ),

                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
