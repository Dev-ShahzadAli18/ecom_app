import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/screens/login_screen.dart';
import 'package:ecom_app/screens/navigation.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/custom_drwaer.dart';
import 'package:ecom_app/widgets/custom_password.dart';
import 'package:ecom_app/widgets/custom_textfield.dart';
import 'package:ecom_app/widgets/custom_validator.dart';
import 'package:ecom_app/widgets/gender_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? selectedGender;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future signup() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      final User? user = credential.user;

      if (user == null) {
        throw Exception("Firebase user is null");
      }
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "id": user.uid,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "gender": selectedGender,
        "Phone Number": phoneController.text.trim(),
        "role": "user",
        "createdAt": FieldValue.serverTimestamp(),
      });

      UserData.name = nameController.text.trim();
      UserData.email = emailController.text.trim();
      UserData.role = "user";

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return MainNavigation(role: "user");
          },
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      final message = e is FirebaseAuthException
          ? e.message ?? e.code
          : e.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup Error: $message")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double horizontalPadding = (screenWidth * 0.06).clamp(16.0, 28.0);
    final double topSpacing = mediaQuery.size.height < 680 ? 16.0 : 25.0;

    Color lineColor = AppColors.isDark
        ? const Color(0xff3A3A3A)
        : const Color(0xffE5E5E5);
    Color orColor = AppColors.isDark
        ? const Color(0xff8A8A8A)
        : const Color(0xff999999);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: topSpacing),

                // Back Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: lineColor),
                    ),
                    child: Icon(Icons.arrow_back, color: AppColors.black),
                  ),
                ),

                SizedBox(height: topSpacing),
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
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 32,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: (screenWidth * 0.07).clamp(22.0, 28.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    "Create an account to shop and track your orders",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                ),

                const SizedBox(height: 25),
                Text(
                  "Full Name",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 8),

                CustomTextField(
                  controller: nameController,
                  hintText: "Enter your full name",
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: Validators.name,
                ),

                const SizedBox(height: 16),

                // EMAIL
                Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 8),

                CustomTextField(
                  controller: emailController,
                  hintText: "Enter your email",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),

                const SizedBox(height: 16),

                // GENDER
                Text(
                  "Gender",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 8),

                CustomDropdownField(
                  value: selectedGender,
                  hint: "Select Gender",
                  items: const ["Male", "Female", "Other"],
                  onChanged: (val) {
                    setState(() {
                      selectedGender = val;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // PHONE NUMBER
                Text(
                  "Phone Number",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 8),

                CustomTextField(
                  controller: phoneController,
                  hintText: "(+92) 300 1234567",
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: Validators.number,
                ),

                const SizedBox(height: 16),

                // PASSWORD
                Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 8),

                CustomPasswordField(
                  controller: passwordController,
                  hintText: "Create a password",
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    return Validators.password(value);
                  },
                ),

                const SizedBox(height: 16),

                // CONFIRM PASSWORD
                Text(
                  "Confirm Password",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 8),

                CustomPasswordField(
                  controller: confirmPasswordController,
                  hintText: "Re-enter your password",
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    return Validators.confirmPassword(
                      value,
                      passwordController.text,
                    );
                  },
                ),

                const SizedBox(height: 28),

                CustomButton(
                  text: isLoading ? "Please wait..." : "Create Account",
                  icon: Icons.arrow_forward,
                  onTap: () {
                    if (isLoading) {
                      return;
                    }

                    signup();
                  },
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(child: Divider(color: lineColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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

                const SizedBox(height: 22),

                // Google sign in placeholder
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

                const SizedBox(height: 26),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(fontSize: 14, color: AppColors.grey),
                      ),
                      GestureDetector(
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
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffD99F00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
