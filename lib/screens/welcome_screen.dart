import 'package:ecom_app/models/welcome_data.dart';
import 'package:ecom_app/screens/onboarding.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.network(
              welcomeData.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: CircularProgressIndicator(color: Color(0xffF5B700)),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.35, 0.58, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Spacer(),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Text(
                        welcomeData.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        welcomeData.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: 25),

                      SizedBox(
                        width: 180,
                        height: 44,
                        child: CustomButton(
                          text: "Get Started",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnboardingPage(),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 75),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
