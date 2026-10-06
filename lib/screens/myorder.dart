import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/widgets/customorderwidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  User? get user {
    return FirebaseAuth.instance.currentUser;
  }

  Stream<QuerySnapshot> getOrders() {
    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("orders")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  double getPrice(Map<String, dynamic> data) {
    if (data["price"] is num) {
      return (data["price"] as num).toDouble();
    }

    return 0;
  }

  double getTotalPrice(Map<String, dynamic> data) {
    if (data["totalPrice"] is num) {
      return (data["totalPrice"] as num).toDouble();
    }

    double price = getPrice(data);

    int quantity = 1;

    if (data["quantity"] is num) {
      quantity = (data["quantity"] as num).toInt();
    }

    return price * quantity;
  }

  int getQuantity(Map<String, dynamic> data) {
    if (data["quantity"] is num) {
      return (data["quantity"] as num).toInt();
    }

    return 1;
  }

  String getDate(Map<String, dynamic> data) {
    Timestamp? timestamp;

    if (data["createdAt"] is Timestamp) {
      timestamp = data["createdAt"];
    }

    if (timestamp == null) {
      return "Date not available";
    }

    DateTime date = timestamp.toDate();

    String day = date.day.toString().padLeft(2, "0");

    String month = date.month.toString().padLeft(2, "0");

    String year = date.year.toString();

    String hour = date.hour.toString().padLeft(2, "0");

    String minute = date.minute.toString().padLeft(2, "0");

    return "$day/$month/$year  $hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text("My Orders", style: AppTextStyles.title),
          centerTitle: true,
        ),
        body: Center(
          child: Text("Please login first", style: AppTextStyles.body),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.black),
        ),
        title: Text("My Orders", style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Something went wrong", style: AppTextStyles.body),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return CustomEmptyOrders();
          }

          final double padding = (MediaQuery.of(context).size.width * 0.045).clamp(12.0, 20.0);

          return ListView.builder(
            padding: EdgeInsets.all(padding),
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];

              Map<String, dynamic> order =
                  document.data() as Map<String, dynamic>;

              return CustomMyOrderCard(
                name: order["name"] ?? "No Name",

                imageUrl: order["imageUrl"] ?? "",

                price: getPrice(order),

                totalPrice: getTotalPrice(order),

                quantity: getQuantity(order),

                color: order["color"] ?? "",

                status: order["status"] ?? "Pending",

                address: order["address"] ?? "",

                date: getDate(order),
              );
            },
          );
        },
      ),
    );
  }
}
