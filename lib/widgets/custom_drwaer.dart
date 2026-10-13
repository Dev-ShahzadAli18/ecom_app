import 'package:ecom_app/main.dart';
import 'package:ecom_app/services/auth_service.dart';
import 'package:ecom_app/screens/add_product.dart';
import 'package:ecom_app/screens/admin_orders.dart';
import 'package:ecom_app/screens/all_product.dart';
import 'package:ecom_app/screens/my_cart.dart';
import 'package:ecom_app/screens/myorder.dart';
import 'package:ecom_app/screens/search.dart';
import 'package:ecom_app/screens/welcome_screen.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/custom_card.dart';
import 'package:ecom_app/widgets/custom_container.dart';
import 'package:ecom_app/widgets/listtile.dart';
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
    final menuItems = <({IconData icon, String title, Widget? page})>[
      (icon: Icons.home_outlined, title: "Homepage", page: null),
      if (isAdmin)
        (
          icon: Icons.add_shopping_cart_outlined,
          title: "Add Product",
          page: AddProductPage(),
        ),
      if (isAdmin)
        (
          icon: Icons.inventory_2_outlined,
          title: "All Products",
          page: AllProductsPage(collectionName: "All", role: role),
        ),
      if (isAdmin)
        (
          icon: Icons.receipt_long_outlined,
          title: "Customer Orders",
          page: AdminOrdersPage(role: role),
        ),
      (icon: Icons.search, title: "Search", page: SearchPage(role: role)),
      if (!isAdmin)
        (
          icon: Icons.shopping_cart_outlined,
          title: "My Cart",
          page: MyCartPage(),
        ),
      if (!isAdmin)
        (
          icon: Icons.receipt_long_outlined,
          title: "My Orders",
          page: MyOrdersPage(),
        ),
      (icon: Icons.person_outline, title: "My Profile", page: null),
    ];

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
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(top: 15, bottom: 12),
                    children: [
                      for (final item in menuItems)
                        _menu(
                          context,
                          item.icon,
                          item.title,
                          selected: item.title == "Homepage",
                          onTap: () {
                            Navigator.pop(context);
                            if (item.page != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => item.page!,
                                ),
                              );
                            }
                          },
                        ),
                      _logout(context),
                    ],
                  ),
                ),
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
    final name = UserData.name.trim();
    final firstLetter = name.isEmpty ? "G" : name[0].toUpperCase();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: CustomCard(
        padding: EdgeInsets.all(15),
        radius: 22,
        backgroundColor: AppColors.isDark
            ? Color(0xff252525)
            : Color(0xffF8F8F8),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.08)),
        boxShadow: [],
        child: Row(
          children: [
            CustomContainer(
              height: 58,
              width: 58,
              padding: EdgeInsets.zero,
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
              child: Center(
                child: Text(
                  firstLetter,
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
            ? Color.fromARGB(255, 42, 42, 42)
            : Color.fromARGB(255, 247, 247, 247),
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
          MaterialPageRoute(builder: (context) => WelcomePage()),
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
    final pillBg = AppColors.isDark
        ? Color.fromARGB(255, 37, 37, 37)
        : Color.fromARGB(255, 243, 244, 246);
    final activeBg = AppColors.isDark
        ? Color.fromARGB(255, 58, 58, 58)
        : Colors.white;

    return CustomContainer(
      height: 44,
      margin: EdgeInsets.symmetric(horizontal: 22),
      padding: EdgeInsets.all(4),
      color: pillBg,
      borderRadius: 25,
      border: Border.all(color: AppColors.grey.withValues(alpha: 0.08)),
      boxShadow: [],
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: "Light",
              onTap: () => saveTheme(false),
              height: 36,
              borderRadius: 21,
              padding: EdgeInsets.zero,
              backgroundColor: AppColors.isDark ? Colors.transparent : activeBg,
              disabledBackgroundColor: AppColors.isDark
                  ? Colors.transparent
                  : activeBg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wb_sunny_rounded,
                    size: 16,
                    color: AppColors.isDark ? AppColors.grey : AppColors.black,
                  ),
                  SizedBox(width: 6),
                  Text("Light", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          Expanded(
            child: CustomButton(
              text: "Dark",
              onTap: () => saveTheme(true),
              height: 36,
              borderRadius: 21,
              padding: EdgeInsets.zero,
              backgroundColor: AppColors.isDark ? activeBg : Colors.transparent,
              disabledBackgroundColor: AppColors.isDark
                  ? activeBg
                  : Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.nightlight_round,
                    size: 16,
                    color: AppColors.isDark ? AppColors.black : AppColors.grey,
                  ),
                  SizedBox(width: 6),
                  Text("Dark", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
