import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;

  final Widget? contentPaddingChild;

  final bool? dense;
  final bool? enabled;
  final bool? selected;
  final bool? autofocus;

  final Color? tileColor;
  final Color? selectedTileColor;
  final Color? iconColor;
  final Color? textColor;

  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;

  final ShapeBorder? shape;

  final double? minVerticalPadding;
  final double? horizontalTitleGap;
  final double? minLeadingWidth;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final MouseCursor? mouseCursor;

  const CustomListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.contentPaddingChild,
    this.dense,
    this.enabled,
    this.selected,
    this.autofocus,
    this.tileColor,
    this.selectedTileColor,
    this.iconColor,
    this.textColor,
    this.contentPadding,
    this.margin,
    this.shape,
    this.minVerticalPadding,
    this.horizontalTitleGap,
    this.minLeadingWidth,
    this.onTap,
    this.onLongPress,
    this.mouseCursor,
  });

  @override
  Widget build(BuildContext context) {
    Widget tile = ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,

      dense: dense,
      enabled: enabled ?? true,
      selected: selected ?? false,
      autofocus: autofocus ?? false,

      tileColor: tileColor,
      selectedTileColor: selectedTileColor,

      iconColor: iconColor,
      textColor: textColor,

      contentPadding: contentPadding,

      shape: shape,

      minVerticalPadding: minVerticalPadding,
      horizontalTitleGap: horizontalTitleGap,
      minLeadingWidth: minLeadingWidth,

      onTap: onTap,
      onLongPress: onLongPress,

      mouseCursor: mouseCursor,
    );

    if (margin != null) {
      tile = Padding(padding: margin!, child: tile);
    }

    return tile;
  }
}
