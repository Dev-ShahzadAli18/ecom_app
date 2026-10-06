import 'package:ecom_app/screens/verification_screen.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/widgets/custom_buttton.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double horizontalPadding = (screenWidth * 0.055).clamp(16.0, 24.0);

    Color lineColor = AppColors.isDark ? const Color(0xff3A3A3A) : const Color(0xffE5E5E5);
    Color arrowColor = AppColors.isDark ? const Color(0xffB0B0B0) : const Color(0xff555555);
    Color descColor = AppColors.isDark ? const Color(0xffB0B0B0) : const Color(0xff4D4D4D);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),

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

                      const SizedBox(height: 35),

                      Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontSize: (screenWidth * 0.055).clamp(20.0, 24.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Enter your email associated with your account\n"
                        "and we'll send you a verification code to\n"
                        "reset your password.",
                        style: TextStyle(fontSize: 12, height: 1.5, color: descColor),
                      ),

                      const SizedBox(height: 35),

                      CustomTextField(
                        controller: emailController,
                        hintText: "Enter your email",
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: CustomButton(
                          text: "Continue",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VerificationCode(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 25),
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
