import 'package:ecom_app/main.dart';
import 'package:ecom_app/screens/add_product.dart';
import 'package:ecom_app/screens/admin_orders.dart';
import 'package:ecom_app/screens/all_product.dart';
import 'package:ecom_app/screens/my_cart.dart';
import 'package:ecom_app/screens/myorder.dart';
import 'package:ecom_app/screens/search.dart';
import 'package:ecom_app/screens/welcome_screen.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_container.dart';
import 'package:ecom_app/widgets/listtile.dart';
import 'package:firebase_logic/firebase_logic.dart';
import 'package:flutter/material.dart';

class UserData {
  static String name = "";
  static String email = "";
  static String role = "user";
}

class CustomDrawer extends StatelessWidget {
  final String role;

  CustomDrawer({super.key, required this.role});

  final AuthService authService = AuthService();

  bool get isAdmin => role == "admin";

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkNotifier,
      builder: (context, isDark, child) {
        return Drawer(
          width: 300,
          backgroundColor: AppColors.white,
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 22),

                _profile(),

                SizedBox(height: 22),

                Divider(
                  height: 1,
                  indent: 22,
                  endIndent: 22,
                  color: AppColors.grey.withValues(alpha: 0.15),
                ),

                SizedBox(height: 15),
                _menu(
                  context,
                  Icons.home_outlined,
                  "Homepage",
                  selected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                if (isAdmin)
                  _menu(
                    context,
                    Icons.add_shopping_cart_outlined,
                    "Add Product",
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AddProductPage();
                          },
                        ),
                      );
                    },
                  ),

                if (isAdmin)
                  _menu(
                    context,
                    Icons.inventory_2_outlined,
                    "All Products",
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AllProductsPage(
                              collectionName: "All",
                              role: role,
                            );
                          },
                        ),
                      );
                    },
                  ),
                if (isAdmin)
                  _menu(
                    context,
                    Icons.receipt_long_outlined,
                    "Customer Orders",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminOrdersPage(role: role),
                        ),
                      );
                    },
                  ),
                _menu(
                  context,
                  Icons.search,
                  "Search",
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SearchPage(role: role);
                        },
                      ),
                    );
                  },
                ),
                if (!isAdmin)
                  _menu(
                    context,
                    Icons.shopping_cart_outlined,
                    "My Cart",
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return MyCartPage();
                          },
                        ),
                      );
                    },
                  ), // USER ONLY

                if (!isAdmin)
                  _menu(
                    context,
                    Icons.receipt_long_outlined,
                    "My Orders",
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return MyOrdersPage();
                          },
                        ),
                      );
                    },
                  ),
                _menu(
                  context,
                  Icons.person_outline,
                  "My Profile",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _logout(context),

                Spacer(),

                _themeSwitch(),

                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _profile() {
    String firstLetter = "";

    if (UserData.name.trim().isNotEmpty) {
      firstLetter = UserData.name.trim()[0].toUpperCase();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.isDark ? Color(0xff252525) : Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  firstLetter.isEmpty ? "G" : firstLetter,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    UserData.name.isEmpty
                        ? "Welcome to GemStore"
                        : UserData.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    UserData.email.isEmpty
                        ? "Your fashion destination"
                        : UserData.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: AppColors.grey),
                  ),

                  SizedBox(height: 7),

                  Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),

                      SizedBox(width: 4),

                      Text(
                        isAdmin ? "GemStore Admin" : "GemStore Member",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menu(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return CustomListTile(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      onTap: onTap,
      dense: true,
      minVerticalPadding: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      tileColor: selected
          ? AppColors.isDark
                ? Color(0xff2C2C2C)
                : Color(0xffF3F4F6)
          : Colors.transparent,
      leading: CustomContainer(
        height: 38,
        width: 38,
        padding: EdgeInsets.zero,
        borderRadius: 11,
        color: selected
            ? AppColors.primary.withValues(alpha: 0.14)
            : AppColors.isDark
            ? Color(0xff2A2A2A)
            : Color(0xffF7F7F7),
        child: Icon(
          icon,
          size: 20,
          color: selected ? AppColors.primary : AppColors.grey,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.black : AppColors.grey,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 12,
        color: AppColors.grey,
      ),
    );
  }

  Widget _logout(BuildContext context) {
    return CustomListTile(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      onTap: () async {
        await authService.logout();

        UserData.name = "";
        UserData.email = "";
        UserData.role = "user";

        if (!context.mounted) {
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return WelcomePage();
            },
          ),
          (route) => false,
        );
      },
      dense: true,
      minVerticalPadding: 4,
      contentPadding: EdgeInsets.symmetric(horizontal: 14),
      leading: CustomContainer(
        height: 38,
        width: 38,
        padding: EdgeInsets.zero,
        color: AppColors.red.withValues(alpha: 0.10),
        borderRadius: 11,
        child: Icon(Icons.logout_rounded, size: 20, color: AppColors.red),
      ),
      title: Text(
        "Logout",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.red,
        ),
      ),
    );
  }

  Widget _themeSwitch() {
    Color pillBg = AppColors.isDark
        ? Color.fromARGB(255, 37, 37, 37)
        : Color.fromARGB(255, 243, 244, 246);

    Color activeBg = AppColors.isDark
        ? Color.fromARGB(255, 58, 58, 58)
        : Colors.white;

    return Container(
      height: 44,
      margin: EdgeInsets.symmetric(horizontal: 22),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                saveTheme(false);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.isDark ? Colors.transparent : activeBg,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wb_sunny_rounded,
                      size: 16,
                      color: AppColors.isDark
                          ? AppColors.grey
                          : AppColors.black,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Light",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.isDark
                            ? AppColors.grey
                            : AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () {
                saveTheme(true);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.isDark ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.nightlight_round,
                      size: 16,
                      color: AppColors.isDark
                          ? AppColors.black
                          : AppColors.grey,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Dark",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.isDark
                            ? AppColors.black
                            : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
