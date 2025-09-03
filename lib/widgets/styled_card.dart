import 'package:baligny_technician/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class StyledCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? elevation;
  final Color? color;
  final Color? shadowColor;

  const StyledCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.color,
    this.shadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      elevation: elevation ?? 2,
      color: color ?? white,
      shadowColor: (shadowColor ?? greyShade3).withOpacity(.25),
      child: Padding(
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: child,
      ),
    );
  }
}
