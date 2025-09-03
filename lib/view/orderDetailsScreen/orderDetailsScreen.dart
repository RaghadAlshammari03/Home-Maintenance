// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/provider/itemOrderProvider/itemOrderProvider.dart';
import 'package:baligny/controller/services/serviceOrderServices/serviceOrderServices.dart';
import 'package:baligny/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/model/userAddressModel/userAddressModel.dart';
import 'package:baligny/model/userModel/userModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/view/trackOrderScreen/track_technician_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

class OrderDetailsScreen extends StatefulWidget {
  final List<ServiceModel> cartItems;
  final UserAddressModel userAddress;
  final UserModel userData;

  const OrderDetailsScreen({
    super.key,
    required this.cartItems,
    required this.userAddress,
    required this.userData,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTimeSlot;
  List<String> timeSlots = ["09:00", "10:00"];
  List<String> unavailableSlots = [];
  final ImagePicker _picker = ImagePicker();

  List<File> _images = [];
  List<File> _videos = [];

  @override
  void initState() {
    super.initState();
    _fetchUnavailableTimes();
  }

  Future<void> _fetchUnavailableTimes() async {
    if (_selectedDay == null) return;
    final dateKey = _selectedDay!.toIso8601String().split("T").first;
    final snapshot = await FirebaseFirestore.instance
        .collection('UnavailableSlots')
        .doc(dateKey)
        .get();
    setState(() {
      unavailableSlots = List<String>.from(snapshot.data()?['times'] ?? []);
    });
  }

  Future<void> _pickMedia({required bool isImage}) async {
    final pickedFile = isImage
        ? await _picker.pickImage(source: ImageSource.gallery)
        : await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        isImage
            ? _images.add(File(pickedFile.path))
            : _videos.add(File(pickedFile.path));
      });
    }
  }

  void _continueToCheckout() async {
    if (_selectedDay == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التاريخ والوقت')),
      );
      return;
    }

    final itemOrderProvider = context.read<ItemOrderProvider>();
    if (itemOrderProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('سلة التسوق فارغة')));
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      // Generate orderID to link all orders
      final orderID = Uuid().v1();

      // Build orders list with all data
      final List<ServiceOrderModel> orders = itemOrderProvider.cartItems.map((
        service,
      ) {
        return ServiceOrderModel(
          servicedetail: service,
          userAddress: widget.userAddress,
          userData: widget.userData,
          orderID: orderID,
          orderStatus: ServiceOrderServices.orderStatus(2),
          userUID: auth.currentUser!.uid,
          orderPlacedAt: DateTime.now(),
        );
      }).toList();

      // Submit orders
      for (var order in orders) {
        await ServiceOrderServices.serviceOrderRequest(
          order,
          order.orderID!,
          context,
        );
      }

      // Clear cart
      await ServiceOrderServices.clearCartItems();
      context.read<ItemOrderProvider>().fetchCartItems();

      // Dismiss loading
      Navigator.of(context).pop();

      // Navigate to tracking page with the first order (or customize)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TrackTechnicianScreen(orderId: orderID),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // dismiss loading if error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ أثناء تقديم الطلب: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'تحديد الموعد والتفاصيل',
              style: AppTextStyles.heading20Bold.copyWith(
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
            titleSpacing: 0.0,
            centerTitle: true,
            toolbarHeight: 80,
            toolbarOpacity: 0.8,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
            elevation: 0.0,
            backgroundColor: lightOrange,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text('اختر التاريخ:', style: AppTextStyles.body16Bold),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  headerStyle: HeaderStyle(formatButtonVisible: false),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _fetchUnavailableTimes();
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedDay != null) ...[
                  const SizedBox(height: 16),
                  Text('اختر الوقت:', style: AppTextStyles.body16Bold),
                  Wrap(
                    spacing: 12,
                    children: timeSlots.map((slot) {
                      final isUnavailable = unavailableSlots.contains(slot);
                      final isSelected = _selectedTimeSlot == slot;
                      return ChoiceChip(
                        label: Text(
                          slot,
                          style: TextStyle(color: isSelected ? white : black),
                        ),
                        selected: isSelected,
                        onSelected: isUnavailable
                            ? null
                            : (selected) {
                                setState(() {
                                  _selectedTimeSlot = slot;
                                });
                              },
                        selectedColor: darkBlue,
                        disabledColor: grey,
                        checkmarkColor: white,
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                Text('أرفق الصور:', style: AppTextStyles.body16Bold),
                ElevatedButton(
                  onPressed: () => _pickMedia(isImage: true),
                  child: const Text("إضافة صورة"),
                ),
                const SizedBox(height: 8),
                if (_images.isNotEmpty)
                  GridView.builder(
                    itemCount: _images.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (context, index) {
                      final file = _images[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              file,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _images.removeAt(index);
                                });
                              },
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: red,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: 24),
                Text('أرفق الفيديو:', style: AppTextStyles.body16Bold),
                ElevatedButton(
                  onPressed: () => _pickMedia(isImage: false),
                  child: const Text("إضافة فيديو"),
                ),
                const SizedBox(height: 8),
                if (_videos.isNotEmpty)
                  GridView.builder(
                    itemCount: _videos.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (context, index) {
                      final file = _videos[index];
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.videocam,
                                size: 40,
                                color: darkBlue,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _videos.removeAt(index);
                                });
                              },
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: red,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _continueToCheckout,
                  child: const Text('متابعة إلى الدفع'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
