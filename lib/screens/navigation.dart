import 'package:ecom_app/screens/favourite_page.dart';
import 'package:ecom_app/screens/honme_screen.dart';
import 'package:ecom_app/screens/profile_screen.dart';
import 'package:ecom_app/screens/search.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  final String role;

  MainNavigation({super.key, required this.role});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color unselectedColor = AppColors.isDark
        ? Color(0xff8A8A8A)
        : Color(0xff999999);

    return Scaffold(
      backgroundColor: AppColors.white,

      body: PageView(
        controller: pageController,

        onPageChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        children: [
          HomePage(role: widget.role),

          SearchPage(role: widget.role),

          FavouritePage(role: widget.role),

          ProfilePage(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });

          pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },

        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        elevation: 12,

        selectedItemColor: AppColors.primary,
        unselectedItemColor: unselectedColor,

        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),

        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: "Search",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: "Favorites",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
