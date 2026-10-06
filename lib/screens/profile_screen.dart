import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/screens/login_screen.dart';
import 'package:ecom_app/screens/profile_details.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/custom_container.dart';
import 'package:ecom_app/widgets/listtile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double horizontalPadding = (screenWidth * 0.05).clamp(14.0, 24.0);
    final double avatarSize = (screenWidth * 0.26).clamp(84.0, 115.0);

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 70, color: AppColors.grey),
              const SizedBox(height: 16),
              Text(
                "Please login to view your profile",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: "Go to Login",
                width: 180,
                height: 48,
                textColor: Colors.white,
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snp) {
          if (snp.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snp.hasData || !snp.data!.exists) {
            return Center(
              child: Text(
                "No profile data found",
                style: TextStyle(color: AppColors.grey),
              ),
            );
          }

          final data = snp.data!.data() as Map<String, dynamic>? ?? {};
          final String role = (data["role"] ?? "user").toString().toUpperCase();

          final profileData = [
            {
              "title": "Name",
              "value": data["name"] ?? "",
              "icon": Icons.person_outline,
            },
            {
              "title": "Email",
              "value": data["email"] ?? user?.email ?? "",
              "icon": Icons.email_outlined,
            },
            {
              "title": "Role",
              "value": role,
              "icon": Icons.admin_panel_settings_outlined,
            },
            {
              "title": "Gender",
              "value": data["gender"] ?? "Not specified",
              "icon": Icons.wc_outlined,
            },
            {
              "title": "Phone",
              "value": data["Phone Number"] ?? data["phone"] ?? "Not specified",
              "icon": Icons.phone_outlined,
            },
          ];

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Account",
                    style: TextStyle(
                      fontSize: (screenWidth * 0.065).clamp(22.0, 26.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Manage your personal information & store settings",
                    style: TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Responsive Centered Avatar
                  Center(
                    child: Container(
                      height: avatarSize,
                      width: avatarSize,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (data["name"] != null &&
                                  data["name"].toString().isNotEmpty)
                              ? data["name"].toString()[0].toUpperCase()
                              : "G",
                          style: TextStyle(
                            fontSize: (avatarSize * 0.42).clamp(32.0, 48.0),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Role: $role",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: profileData.length,
                      itemBuilder: (context, index) {
                        final item = profileData[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CustomContainer(
                            height: 84,
                            width: double.infinity,
                            color: AppColors.white,
                            child: CustomListTile(
                              onTap: () {
                                if (item["title"] != "Role") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileDetail(
                                        title: item["title"].toString(),
                                        oldvalue: item["value"].toString(),
                                      ),
                                    ),
                                  );
                                }
                              },
                              leading: CustomContainer(
                                height: 48,
                                width: 48,
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: 12,
                                child: Center(
                                  child: Icon(
                                    item["icon"] as IconData,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                              ),
                              title: Text(
                                item["title"].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                  color: AppColors.black,
                                ),
                              ),
                              subtitle: Text(
                                item["value"].toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 12.5,
                                ),
                              ),
                              trailing: item["title"] != "Role"
                                  ? Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: AppColors.grey,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
