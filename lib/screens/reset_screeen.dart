import 'package:ecom_app/screens/login_screen.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double horizontalPadding = (screenWidth * 0.055).clamp(16.0, 24.0);

    Color lineColor = AppColors.isDark ? const Color(0xff3A3A3A) : const Color(0xffE5E5E5);
    Color arrowColor = AppColors.isDark ? const Color(0xffB0B0B0) : const Color(0xff555555);
    Color descColor = AppColors.isDark ? const Color(0xffB0B0B0) : const Color(0xff535252);

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
                        "Create new password",
                        style: TextStyle(
                          fontSize: (screenWidth * 0.055).clamp(20.0, 24.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Your new password must be different\n"
                        "from previously used password.",
                        style: TextStyle(fontSize: 12, height: 1.5, color: descColor),
                      ),

                      const SizedBox(height: 35),

                      CustomTextField(
                        controller: passwordController,
                        hintText: "New Password",
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                      ),

                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: confirmPasswordController,
                        hintText: "Confirm Password",
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: CustomButton(
                          text: "Confirm",
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return LoginPage();
                                },
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
