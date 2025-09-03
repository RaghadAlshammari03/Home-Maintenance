import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FullWidthFloatingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;
  final bool visible;
  final bool compact;
  final double? verticalPadding;

  const FullWidthFloatingButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.leading,
    this.visible = true,
    this.compact = false,
    this.verticalPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final double padV = verticalPadding ?? (compact ? 1.5.h : 1.6.h);
    final double horPadding = 4.w;
    final textStyle = compact
        ? AppTextStyles.body16Bold.copyWith(color: Colors.white)
        : AppTextStyles.body18Bold.copyWith(color: Colors.white);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horPadding,
          vertical: padV * 0.8,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBlue,
              padding: EdgeInsets.symmetric(vertical: padV),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (leading != null) ...[leading!, SizedBox(width: 2.w)],
                      Text(label, style: textStyle),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
