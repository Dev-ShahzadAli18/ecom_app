import 'package:ecom_app/screens/welcome_screen.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

ValueNotifier<bool> darkNotifier = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkNotifier,
      builder: (context, isDark, child) {
        AppColors.isDark = isDark;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GemStore',
          home: const WelcomePage(),
        );
      },
    );
  }
}
