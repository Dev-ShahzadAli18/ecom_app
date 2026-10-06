import 'package:ecom_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomRoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const CustomRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isCompact = screenWidth < 360;

    final roles = [
      {
        "id": "buyer",
        "title": "Buyer",
        "subtitle": "Shop & Order",
        "icon": Icons.shopping_bag_outlined,
      },
      {
        "id": "seller",
        "title": "Seller",
        "subtitle": "Sell & Manage",
        "icon": Icons.storefront_outlined,
      },
      {
        "id": "admin",
        "title": "Admin",
        "subtitle": "Full Access",
        "icon": Icons.admin_panel_settings_outlined,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.isDark ? const Color(0xff222222) : const Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.isDark ? const Color(0xff333333) : const Color(0xffE5E5E5),
        ),
      ),
      child: Row(
        children: roles.map((role) {
          final bool isSelected = selectedRole.toLowerCase() == (role["id"] as String).toLowerCase();
          final String title = role["title"] as String;
          final String subtitle = role["subtitle"] as String;
          final IconData icon = role["icon"] as IconData;

          return Expanded(
            child: GestureDetector(
              onTap: () => onRoleChanged(role["id"] as String),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  vertical: isCompact ? 8 : 10,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: isCompact ? 18 : 22,
                      color: isSelected
                          ? Colors.black
                          : (AppColors.isDark ? AppColors.grey : const Color(0xff666666)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isCompact ? 11 : 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.black
                            : AppColors.black,
                      ),
                    ),
                    if (!isCompact) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.black.withValues(alpha: 0.75)
                              : AppColors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
