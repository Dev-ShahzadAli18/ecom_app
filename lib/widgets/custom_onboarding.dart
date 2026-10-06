import 'package:ecom_app/models/onboardingmodels.dart';
import 'package:flutter/material.dart';

class CustomOnboardingCard extends StatelessWidget {
  final OnboardingModel data;

  const CustomOnboardingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),

      child: Column(
        children: [
          Expanded(
            flex: 6,

            child: Center(
              child: Image.asset(
                data.image,

                fit: BoxFit.contain,

                width: double.infinity,
              ),
            ),
          ),

          Expanded(
            flex: 3,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(
                  data.title,

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff111111),
                  ),
                ),

                SizedBox(height: 14),

                Text(
                  data.description,

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color.fromARGB(255, 119, 119, 119),
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
