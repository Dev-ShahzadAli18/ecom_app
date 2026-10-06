import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/custom_container.dart';
import 'package:ecom_app/widgets/custom_iconbutton.dart';
import 'package:ecom_app/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileDetail extends StatefulWidget {
  final String title;
  final String oldvalue;

  ProfileDetail({super.key, required this.title, required this.oldvalue});

  @override
  State<ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  late final TextEditingController editcontroller;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    editcontroller = TextEditingController(text: widget.oldvalue);
  }

  @override
  void dispose() {
    editcontroller.dispose();
    super.dispose();
  }

  Future<void> updateData() async {
    if (editcontroller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Value cannot be empty")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      String fieldKey = "name";
      if (widget.title.toLowerCase() == "email") {
        fieldKey = "email";
      } else if (widget.title.toLowerCase() == "phone") {
        fieldKey = "Phone Number";
      } else if (widget.title.toLowerCase() == "gender") {
        fieldKey = "gender";
      }

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        fieldKey: editcontroller.text.trim(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile updated successfully")));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Update failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        title: Text(
          "Edit ${widget.title}",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          CustomIconButton(
            onTap: isLoading ? null : updateData,
            icon: Icons.check,
          ),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                widget.title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 8),
            CustomContainer(
              width: double.infinity,
              padding: EdgeInsets.all(4),
              color: Colors.white,
              borderRadius: 15,
              child: CustomTextField(controller: editcontroller),
            ),
            SizedBox(height: 25),
            CustomButton(
              text: isLoading ? "Updating..." : "Update ${widget.title}",
              loading: isLoading,
              onTap: updateData,
            ),
          ],
        ),
      ),
    );
  }
}
