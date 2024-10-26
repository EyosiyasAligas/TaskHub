import 'package:flutter/material.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String titleText;
  final Widget? titleWidget;
  final bool isBackButtonShown;
  final Color? backgroundColor;
  final Color? titleColor;
  final double expandedHeight;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? flexibleSpaceContent;
  final double? elevation;
  final bool pinned;
  final bool floating;

  const CustomSliverAppBar({
    super.key,
    required this.titleText,
    this.titleWidget,
    this.isBackButtonShown = true,
    this.backgroundColor,
    this.titleColor,
    this.expandedHeight = 200.0,
    this.actions,
    this.leading,
    this.flexibleSpaceContent,
    this.elevation,
    this.pinned = false,
    this.floating = false,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return SliverAppBar(
      title: titleWidget ?? Text(
        titleText,
        style: TextStyle(
          color: titleColor ?? themeData.textTheme.bodyLarge!.color,
        ),
      ),
      backgroundColor: backgroundColor ?? themeData.scaffoldBackgroundColor,
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      elevation: elevation,
      leading: isBackButtonShown
          ? (leading ??
              IconButton(
                icon: Icon(Icons.arrow_back, color: titleColor ?? Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ))
          : null,
      actions: actions,
      flexibleSpace: flexibleSpaceContent != null
          ? FlexibleSpaceBar(
              background: flexibleSpaceContent,
            )
          : null,
    );
  }
}
