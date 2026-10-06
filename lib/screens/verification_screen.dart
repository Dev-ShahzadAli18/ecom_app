import 'package:ecom_app/screens/reset_screeen.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_otp.dart';
import 'package:flutter/material.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';

class VerificationCode extends StatefulWidget {
  VerificationCode({super.key});

  @override
  State<VerificationCode> createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double horizontalPadding = (screenWidth * 0.055).clamp(16.0, 24.0);

    Color lineColor = AppColors.isDark ? Color(0xff3A3A3A) : Color(0xffE5E5E5);
    Color arrowColor = AppColors.isDark ? Color(0xffB0B0B0) : Color(0xff555555);
    Color descColor = AppColors.isDark ? Color(0xffB0B0B0) : Color(0xff5A5959);

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
                        "Verification code",
                        style: TextStyle(
                          fontSize: (screenWidth * 0.055).clamp(20.0, 24.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Please enter the verification code we sent\n"
                        "to your email address.",
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: descColor,
                        ),
                      ),

                      SizedBox(height: 40),

                      Center(
                        child: CustomOtpField(
                          controller: otpController,
                          length: 4,
                          onChanged: (value) {},
                        ),
                      ),

                      SizedBox(height: 18),

                      Center(
                        child: Text(
                          "Resend in 00:30",
                          style: TextStyle(fontSize: 12, color: descColor),
                        ),
                      ),

                      Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: CustomButton(
                          text: "Verify",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResetPassword(),
                              ),
                            );
                          },
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
