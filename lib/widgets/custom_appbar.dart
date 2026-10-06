import 'package:ecom_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  final bool showBackButton;

  final List<Widget>? actions;

  final VoidCallback? onBack;

  final Widget? leading;

  CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.onBack,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,

      elevation: 0,

      scrolledUnderElevation: 0,

      centerTitle: false,

      automaticallyImplyLeading: false,

      leading:
          leading ??
          (showBackButton
              ? IconButton(
                  onPressed:
                      onBack ??
                      () {
                        Navigator.pop(context);
                      },
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.black,
                    size: 20,
                  ),
                )
              : null),

      title: Text(
        title,
        style: TextStyle(
          color: AppColors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
