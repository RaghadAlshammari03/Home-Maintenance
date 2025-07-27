import 'package:baligny/controller/services/serviceOrderServices/serviceOrderServices.dart';
import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/widgets/toastService.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ServiceCard extends StatefulWidget {
  const ServiceCard({required this.service, super.key});

  final ServiceModel service;

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      shadowColor: greyShade3,
      color: white,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.name,
              style: AppTextStyles.body18Bold.copyWith(
                color: lightOrange,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            SizedBox(height: 1.h),
            Text(
              service.detail,
              style: AppTextStyles.body14,
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            SizedBox(height: 2.h),

            // Quantity Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (quantity > 0) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                      child: Container(
                        height: 3.5.h,
                        width: 3.5.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.remove, size: 2.h, color: black),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(quantity.toString(), style: AppTextStyles.body16Bold),
                    SizedBox(width: 2.w),
                    InkWell(
                      onTap: () {
                        setState(() {
                          quantity++;
                        });
                      },
                      child: Container(
                        height: 3.5.h,
                        width: 3.5.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add, size: 2.h, color: black),
                      ),
                    ),
                  ],
                ),

                // Add to Cart Button
                ElevatedButton(
                  onPressed: () async {
                    int qtyToAdd = quantity > 0 ? quantity : 1;

                    ServiceModel serviceData = ServiceModel(
                      id: service.id,
                      name: service.name,
                      detail: service.detail,
                      major: service.major,
                      type: service.type,
                      quantity: qtyToAdd,
                      addedToCartAt: DateTime.now(),
                    );
                    await ServiceOrderServices.addServiceToCart(
                      serviceData,
                      context,
                    );

                    // Reset quantity
                    setState(() => quantity = 0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'أضف للسلة',
                    style: AppTextStyles.body14.copyWith(color: white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
