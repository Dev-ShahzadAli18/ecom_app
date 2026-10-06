import 'package:ecom_app/screens/auth_gate.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier<bool> darkNotifier = ValueNotifier(false);

Future loadTheme() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool isDark = prefs.getBool("isDarkMode") ?? false;

  darkNotifier.value = isDark;
}

Future saveTheme(bool isDark) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setBool("isDarkMode", isDark);

  darkNotifier.value = isDark;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await loadTheme();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkNotifier,
      builder: (context, isDark, child) {
        AppColors.isDark = isDark;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GemStore',
          home: AuthGate(),
        );
      },
    );
  }
}
