import 'dart:io';

import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/services/serviceOrderServices/serviceOrderServices.dart';
import 'package:baligny/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/view/basketScreen/basketScreen.dart';
import 'package:baligny/widgets/toastService.dart';
import 'package:baligny/controller/provider/itemOrderProvider/itemOrderProvider.dart';
import 'package:baligny/controller/provider/profileProvider/profileProvider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:baligny/controller/provider/orderProvider/orderProvider.dart';
import 'package:baligny/widgets/service_card_widget.dart';
import 'package:baligny/widgets/full_width_floating_button.dart';
import 'package:baligny/view/home/viewAddressOverlayScreen.dart';

class SubmitProblemScreen extends StatefulWidget {
  const SubmitProblemScreen({Key? key}) : super(key: key);

  @override
  State<SubmitProblemScreen> createState() => _SubmitProblemScreenState();
}

class _SubmitProblemScreenState extends State<SubmitProblemScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _picked = [];
  final TextEditingController _descCtrl = TextEditingController();
  bool _submitting = false;

  Future<void> _pickImages() async {
    try {
      final List<XFile>? files = await _picker.pickMultiImage(imageQuality: 80);
      if (files != null && files.isNotEmpty) {
        setState(() => _picked.addAll(files));
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  Future<List<String>> _uploadImages(String orderId) async {
    final List<String> urls = [];
    final userId = auth.currentUser!.uid;
    for (int i = 0; i < _picked.length; i++) {
      final file = File(_picked[i].path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('orders')
          .child(userId)
          .child(orderId)
          .child('${uuid.v1()}_${i.toString()}.jpg');
      final task = await ref.putFile(file);
      final dl = await task.ref.getDownloadURL();
      urls.add(dl);
    }
    return urls;
  }

  Future<void> _submit() async {
    final itemProv = context.read<ItemOrderProvider>();
    final profileProv = context.read<ProfileProvider>();
    final cartItems = itemProv.cartItems;
    if (cartItems.isEmpty) return;

    setState(() => _submitting = true);

    final orderId = uuid.v1();
    try {
      final uploaded = await _uploadImages(orderId);

      final order = ServiceOrderModel(
        servicedetail: cartItems.first,
        services: cartItems,
        userAddress: profileProv.activeAddress,
        userData: profileProv.userData,
        orderID: orderId,
        orderStatus: ServiceOrderServices.orderStatus(0),
        userUID: auth.currentUser!.uid,
        orderPlacedAt: DateTime.now(),
        problemDescription: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        attachedImages: uploaded.isEmpty ? null : uploaded,
      );

      await ServiceOrderServices.serviceOrderRequest(order, orderId, context);

      await ServiceOrderServices.clearCartItems();
      itemProv.fetchCartItems();
      // Refresh current order provider if exists
      try {
        context.read<OrderProvider>().fetchCurrentOrder(auth.currentUser!.uid);
      } catch (_) {}

      // Navigate back to BasketScreen where the order will be listed
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BasketScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Submit order error: $e');
      ToastService.sendScaffoldAlert(
        msg: 'فشل في إرسال الطلب',
        toastStatus: 'ERROR',
        context: context,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'تفاصيل الطلب',
              style: AppTextStyles.heading20Bold.copyWith(
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
            titleSpacing: 00.0,
            centerTitle: true,
            toolbarHeight: 80,
            toolbarOpacity: 0.8,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
            elevation: 0.00,
            backgroundColor: lightOrange,
            foregroundColor: Colors.white,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Address chooser
                      SizedBox(height: 2.h),
                      Text(
                        'اختر العنوان',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Consumer<ProfileProvider>(builder: (context, prov, _) {
                        final addr = prov.activeAddress;
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(addr?.addressTitle ?? 'لم يتم اختيار عنوان', style: AppTextStyles.body16Bold),
                                      const SizedBox(height: 6),
                                      Text(
                                        addr != null ? '${addr.roomNo}, ${addr.apartment}' : 'اضغط لتحديد العنوان أو إضافته',
                                        style: AppTextStyles.body14.copyWith(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => const ViewAddressOverlayScreen(),
                                    );
                                    // refresh addresses after returning
                                    try {
                                      prov.fetchUserAddress();
                                    } catch (_) {}
                                    if (mounted) setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
                                  child: Text('اختيار', style: AppTextStyles.body14.copyWith(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: 2.h),
                      Text(
                        'أضف صور للمشكلة (اختياري)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      SizedBox(
                        height: 18.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _picked.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _picked.length) {
                              return GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                  width: 28.w,
                                  margin: EdgeInsets.only(right: 3.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 28,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            }
                            final xf = _picked[index];
                            // display picked image with delete option
                            return Container(
                              width: 28.w,
                              margin: EdgeInsets.only(right: 3.w),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(xf.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: InkWell(
                                      onTap: () => setState(
                                        () => _picked.removeAt(index),
                                      ),
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.black
                                            .withOpacity(0.5),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 2.h),

                      Text(
                        'وصف المشكلة (اختياري)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.2.h),
                      TextField(
                        controller: _descCtrl,
                        minLines: 4,
                        maxLines: 12,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'اكتب وصفا موجزا للمشكلة',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      
                      // Order items list with quantity controls
                      Consumer<ItemOrderProvider>(
                        builder: (context, itemProv, _) {
                          final items = itemProv.cartItems;
                          if (items.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Text(
                                'لا توجد خدمات في السلة',
                                style: AppTextStyles.body14.copyWith(
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final svc in items) ...[
                                ServiceCardWidget(
                                  service: svc,
                                  showQuantityControls: true,
                                ),
                              ],
                              SizedBox(height: 0.4.h),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: FullWidthFloatingButton(
            label: 'إرسال الطلب',
            onPressed: _submitting ? null : _submit,
            isLoading: _submitting,
            compact: true,
          ),
        ),
      ),
    );
  }
}
