import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/services/serviceOrderServices/serviceOrderServices.dart';
import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ServiceCardWidget extends StatefulWidget {
  final ServiceModel service;
  final bool showAddButton; // for services listing
  final bool showQuantityControls; // for cart / submit screens
  final bool compact; // reduced padding for order detail usage
  final VoidCallback? onAddToCart;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const ServiceCardWidget({
    Key? key,
    required this.service,
    this.showAddButton = false,
    this.showQuantityControls = false,
    this.compact = false,
    this.onAddToCart,
    this.onIncrement,
    this.onDecrement,
  }) : super(key: key);

  @override
  State<ServiceCardWidget> createState() => _ServiceCardWidgetState();
}

class _ServiceCardWidgetState extends State<ServiceCardWidget> {
  @override
  Widget build(BuildContext context) {
    final svc = widget.service;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 2.w,
        vertical: widget.compact ? 0.6.h : 1.h,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: widget.compact ? 0 : 2,
      color: white,
      shadowColor: greyShade3.withOpacity(.25),
      child: Padding(
        padding: widget.compact
            ? EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h)
            : EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              svc.name ?? 'الخدمة',
              style: AppTextStyles.body16Bold.copyWith(color: darkBlue),
            ),
            if ((svc.detail ?? '').trim().isNotEmpty) ...[
              SizedBox(height: widget.compact ? 0.4.h : 0.6.h),
              Text(
                svc.detail!,
                style: AppTextStyles.body14.copyWith(color: Colors.black54),
              ),
            ],

            SizedBox(height: widget.compact ? 1.h : 1.6.h),

            // Bottom row: quantity (left) and optional add button (right)
            Row(
              children: [
                // Quantity controls on the left (bottom-left visually)
                if (widget.showQuantityControls) ...[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: greyShade3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap:
                              widget.onDecrement ??
                              () {
                                if (svc.orderID != null &&
                                    svc.quantity != null) {
                                  ServiceOrderServices.updateQuantity(
                                    svc.orderID!,
                                    svc.quantity!,
                                    context,
                                    false,
                                  );
                                }
                              },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            child: Icon(
                              Icons.remove,
                              color: darkBlue,
                              size: 2.h,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: Text(
                            '${svc.quantity ?? 0}',
                            style: AppTextStyles.body16Bold,
                          ),
                        ),
                        InkWell(
                          onTap:
                              widget.onIncrement ??
                              () {
                                if (svc.orderID != null &&
                                    svc.quantity != null) {
                                  ServiceOrderServices.updateQuantity(
                                    svc.orderID!,
                                    svc.quantity!,
                                    context,
                                    true,
                                  );
                                }
                              },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            child: Icon(Icons.add, color: darkBlue, size: 2.h),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                Spacer(),

                // Add-to-cart button on the right when needed
                if (widget.showAddButton)
                  ElevatedButton(
                    onPressed:
                        widget.onAddToCart ??
                        () async {
                          // default behavior: add one to cart
                          int qtyToAdd = 1;
                          String serviceID = uuid.v1();
                          ServiceModel serviceData = ServiceModel(
                            serviceID: widget.service.serviceID,
                            name: widget.service.name,
                            detail: widget.service.detail,
                            major: widget.service.major,
                            type: widget.service.type,
                            quantity: qtyToAdd,
                            orderID: serviceID,
                            addedToCartAt: DateTime.now(),
                          );
                          await ServiceOrderServices.addServiceToCart(
                            serviceData,
                            context,
                          );
                          try {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                            });
                          } catch (_) {}
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'أضف للسلة',
                      style: AppTextStyles.body14.copyWith(color: white),
                    ),
                  ),
                // When not showing controls, show simple quantity label if available
                if (!widget.showQuantityControls && (svc.quantity != null))
                  Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: Text(
                      'الكمية: ${svc.quantity}',
                      style: AppTextStyles.body14.copyWith(
                        color: Colors.black45,
                      ),
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
