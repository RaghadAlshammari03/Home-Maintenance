import 'package:baligny/controller/provider/itemOrderProvider/itemOrderProvider.dart';
import 'package:baligny/controller/services/serviceOrderServices/serviceOrderServices.dart';
import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreensState();
}

class _OrdersScreensState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<ItemOrderProvider>().fetchCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ItemOrderProvider>(
        builder: (context, itemOrderProvider, child) {
          if (itemOrderProvider.cartItems.isEmpty) {
            return Center(
              child: Text('السلة فارغة', style: AppTextStyles.body16),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
              itemCount: itemOrderProvider.cartItems.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                ServiceModel service = itemOrderProvider.cartItems[index];
                int quantity = service.quantity ?? 1;
                return Column(
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
                                child: Icon(
                                  Icons.remove,
                                  size: 2.h,
                                  color: black,
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              quantity.toString(),
                              style: AppTextStyles.body16Bold,
                            ),
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

                        // Delete service from cart Button
                        ElevatedButton(
                          onPressed: () {},
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
                );
              },
            );
          }
        },
      ),
    );
  }
}
