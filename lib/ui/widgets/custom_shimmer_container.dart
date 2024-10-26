import 'package:flutter/material.dart';

import '../../utils/ui_utils.dart';
import '../styles/colors.dart';

class CustomShimmerContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;

  const CustomShimmerContainer({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      height: height ?? UiUtils.shimmerLoadingContainerDefaultHeight,
      decoration: BoxDecoration(
        color: shimmerContentColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 10),
      ),
    );
  }
}
