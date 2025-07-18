import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      shadowColor: greyShade3,
      color: white,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Column(
              children: [
                Text(
                  title,
                  style: AppTextStyles.body18Bold.copyWith(
                    color: lightOrange,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.right,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                SizedBox(height: 1.h),
                Text(
                  description,
                  style: AppTextStyles.body14,
                  textAlign: TextAlign.right,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(5),
                  ),
                ),
                child: Text(
                  'أضف للسلة',
                  style: AppTextStyles.body14.copyWith(color: white),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
