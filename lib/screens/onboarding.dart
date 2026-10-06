import 'package:ecom_app/models/onboarding_data.dart';
import 'package:ecom_app/screens/login_screen.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  PageController pageController = PageController(viewportFraction: 0.72);

  int currentIndex = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (currentIndex < onboardingData.length - 1) {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 68, 66, 68),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 4,
              child: IconButton(
                tooltip: "Back",
                onPressed: () {
                  if (currentIndex > 0) {
                    pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                icon: Icon(Icons.arrow_back, color: Color(0xff222222)),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: screenHeight * 0.58,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
            Positioned(
              top: 25,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: Text(
                      onboardingData[currentIndex].title,
                      key: ValueKey(onboardingData[currentIndex].title),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff222222),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 7),

                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: Text(
                      onboardingData[currentIndex].description,
                      key: ValueKey(onboardingData[currentIndex].description),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: screenHeight * 0.15,
              left: 0,
              right: 0,
              bottom: screenHeight * 0.23,
              child: PageView.builder(
                controller: pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = onboardingData[index];

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xffE6E7E9),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        data.image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return Center(
                            child: CircularProgressIndicator(
                              color: Color(0xffF5B700),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 25,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(onboardingData.length, (index) {
                      bool isActive = index == currentIndex;

                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        height: 7,
                        width: isActive ? 24 : 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Color(0xffF5B700)
                              : Color(0xff999999),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: 25),
                  CustomButton(
                    text: "Shopping now",
                    onTap: nextPage,
                    width: 180,
                    height: 45,
                    borderRadius: 30,
                    textColor: Colors.black,
                    fontSize: 13,
                    side: BorderSide(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
