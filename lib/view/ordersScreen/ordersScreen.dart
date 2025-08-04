// ignore_for_file: use_build_context_synchronously

import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/provider/itemOrderProvider/itemOrderProvider.dart';
import 'package:baligny/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny/controller/services/serviceOrderServices/serviceOrderServices.dart';
import 'package:baligny/model/serviceOrderModel/serviceOrderModel.dart';
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
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Consumer<ItemOrderProvider>(
              builder: (context, itemOrderProvider, child) {
                if (itemOrderProvider.cartItems.isEmpty) {
                  return Center(
                    child: Text('السلة فارغة', style: AppTextStyles.body16),
                  );
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.only(
                      left: 3.w,
                      right: 3.w,
                      top: 2.h,
                      bottom: 12.h,
                    ),
                    itemCount: itemOrderProvider.cartItems.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      ServiceModel serviceData =
                          itemOrderProvider.cartItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 1.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        shadowColor: greyShade3,
                        color: white,
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                serviceData.name,
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
                                serviceData.detail,
                                style: AppTextStyles.body14,
                                textAlign: TextAlign.right,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                              SizedBox(height: 2.h),

                              // Quantity Selector
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          ServiceOrderServices.updateQuantity(
                                            serviceData.orderID!,
                                            serviceData.quantity!,
                                            context,
                                            false,
                                          );
                                        },
                                        child: Container(
                                          height: 3.5.h,
                                          width: 3.5.h,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: grey),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                        serviceData.quantity.toString(),
                                        style: AppTextStyles.body16Bold,
                                      ),

                                      SizedBox(width: 2.w),
                                      InkWell(
                                        onTap: () {
                                          ServiceOrderServices.updateQuantity(
                                            serviceData.orderID!,
                                            serviceData.quantity!,
                                            context,
                                            true,
                                          );
                                        },
                                        child: Container(
                                          height: 3.5.h,
                                          width: 3.5.h,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: grey),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            size: 2.h,
                                            color: black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),

            // Floating "Order Now" Button
            Consumer<ItemOrderProvider>(
              builder: (context, itemOrderProvider, _) {
                return itemOrderProvider.cartItems.isEmpty
                    ? const SizedBox.shrink()
                    : Positioned(
                        bottom: 2.h,
                        left: 4.w,
                        right: 4.w,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkBlue,
                            foregroundColor: white,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final itemOrderProvider = context
                                .read<ItemOrderProvider>();
                            String orderID = uuid.v1();

                            if (itemOrderProvider.cartItems.isEmpty) return;

                            final List<ServiceOrderModel> serviceOrderData =
                                List.generate(
                                  itemOrderProvider.cartItems.length,
                                  (index) => ServiceOrderModel(
                                    servicedetail:
                                        itemOrderProvider.cartItems[index],
                                    userAddress: context
                                        .read<ProfileProvider>()
                                        .activeAddress,
                                    userData: context
                                        .read<ProfileProvider>()
                                        .userData,
                                    orderID: orderID,
                                    orderStatus:
                                        ServiceOrderServices.orderStatus(0),
                                    userUID: auth.currentUser!.uid,
                                    orderPlacedAt: DateTime.now(),
                                  ),
                                );

                            for (final order in serviceOrderData) {
                              await ServiceOrderServices.serviceOrderRequest(
                                order,
                                order.orderID!,
                                context,
                              );
                            }
                            await ServiceOrderServices.clearCartItems();
                            context.read<ItemOrderProvider>().fetchCartItems();
                            debugPrint(
                              "${serviceOrderData.length} orders submitted.",
                            );
                          },
                          child: Text(
                            "اطلب الآن",
                            style: AppTextStyles.body18Bold.copyWith(
                              color: white,
                            ),
                          ),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
