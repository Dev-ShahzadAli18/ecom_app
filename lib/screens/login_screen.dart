import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/screens/forget_password.dart';
import 'package:ecom_app/screens/navigation.dart';
import 'package:ecom_app/screens/signin_scren.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/custom_drwaer.dart';
import 'package:ecom_app/widgets/custom_password.dart';
import 'package:ecom_app/widgets/custom_textfield.dart';
import 'package:ecom_app/widgets/custom_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_logic/firebase_logic.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final AuthService authService = AuthService();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    AuthResult result = await authService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (result.success) {
      UserData.name = result.name;
      UserData.email = result.email;

      String finalRole = result.role.trim().toLowerCase();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.uid)
              .get();

          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            if (data["role"] != null && data["role"].toString().isNotEmpty) {
              finalRole = data["role"].toString().toLowerCase();
            }
            if (data["name"] != null && data["name"].toString().isNotEmpty) {
              UserData.name = data["name"];
            }
            if (data["email"] != null && data["email"].toString().isNotEmpty) {
              UserData.email = data["email"];
            }
          }
        } catch (e) {
          debugPrint("Error fetching Firestore user profile on login: $e");
        }
      }

      finalRole = finalRole == "admin" ? "admin" : "user";

      UserData.role = finalRole;

      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return MainNavigation(role: finalRole);
          },
        ),
        (route) => false,
      );
    } else {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double horizontalPadding = (screenWidth * 0.06).clamp(16.0, 28.0);
    final double topSpacing = mediaQuery.size.height < 680 ? 20.0 : 35.0;

    Color lineColor = AppColors.isDark ? Color(0xff3A3A3A) : Color(0xffE5E5E5);
    Color orColor = AppColors.isDark ? Color(0xff8A8A8A) : Color(0xff999999);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          physics: BouncingScrollPhysics(),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: topSpacing),

                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: "Back",
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back, color: AppColors.black),
                  ),
                ),

                Center(
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 32,
                      color: Colors.black,
                    ),
                  ),
                ),

                SizedBox(height: 25),

                Center(
                  child: Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: (screenWidth * 0.07).clamp(22.0, 28.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),

                SizedBox(height: 8),

                Center(
                  child: Text(
                    "Login to continue shopping & managing your store",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.grey),
                  ),
                ),

                SizedBox(height: 35),

                Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),

                SizedBox(height: 8),

                CustomTextField(
                  controller: emailController,
                  hintText: "Enter your email",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),

                SizedBox(height: 18),

                Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),

                SizedBox(height: 8),

                CustomPasswordField(
                  controller: passwordController,
                  hintText: "Enter your password",
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    return Validators.password(value);
                  },
                ),

                SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ForgotPassword();
                          },
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xffD99F00),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 25),

                CustomButton(
                  text: isLoading ? "Please wait..." : "Login",
                  icon: Icons.arrow_forward,
                  onTap: () {
                    if (isLoading) {
                      return;
                    }

                    login();
                  },
                ),

                SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(child: Divider(color: lineColor)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          fontSize: 12,
                          color: orColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: lineColor)),
                  ],
                ),

                SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.g_mobiledata,
                      size: 30,
                      color: AppColors.black,
                    ),
                    label: Text(
                      "Continue with Google",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: lineColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.grey, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return SignupPage();
                              },
                            ),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xffD99F00),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
