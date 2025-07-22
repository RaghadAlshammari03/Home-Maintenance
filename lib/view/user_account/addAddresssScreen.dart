// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny/controller/services/locationServices/locationServices.dart';
import 'package:baligny/controller/services/userDataCRUDServices/userDataCRUDServices.dart';
import 'package:baligny/model/userAddressModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/widgets/toastService.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AddAddresssScreen extends StatefulWidget {
  const AddAddresssScreen({super.key});

  @override
  State<AddAddresssScreen> createState() => _AddAddresssScreenState();
}

class _AddAddresssScreenState extends State<AddAddresssScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController houseNumberController = TextEditingController();
  TextEditingController apartmentController = TextEditingController();
  String? selectedAddressTitle;
  bool isButtonEnabled = false;
  bool registerButtonPressed = false;
  LatLng? _pickedLocation;

  final List<String> addressOptions = ['المنزل', 'العائلة', 'العمل'];

  final Set<Marker> _markers = {};
  final Completer<GoogleMapController> _googleMapController = Completer();
  GoogleMapController? _mapController;

  bool _isLoading = true;
  CameraPosition? _initialCameraPosition;

  void _validateForm() {
    final isValid =
        houseNumberController.text.isNotEmpty &&
        apartmentController.text.isNotEmpty &&
        selectedAddressTitle != null &&
        selectedAddressTitle!.isNotEmpty;

    setState(() {
      isButtonEnabled = isValid;
    });
  }

  @override
  void dispose() {
    houseNumberController.dispose();
    apartmentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
    houseNumberController.addListener(_validateForm);
    apartmentController.addListener(_validateForm);
  }

  Future<void> _loadInitialLocation() async {
    Position? currentPosition = await LocationServices.getCurrentLocation();
    if (!mounted) return;
    if (currentPosition != null) {
      LatLng userLatLng = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );
      _markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: userLatLng,
          infoWindow: const InfoWindow(title: "موقعي الحالي"),
        ),
      );

      setState(() {
        _initialCameraPosition = CameraPosition(target: userLatLng, zoom: 16);
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _initialCameraPosition = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تعذر تحديد الموقع الحالي")),
        );
      }
    }
  }

  Future<void> _updateUserLocation() async {
    Position? currentPosition = await LocationServices.getCurrentLocation();

    if (currentPosition != null) {
      LatLng userLatLng = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLatLng, zoom: 16),
        ),
      );

      if (!mounted) return;
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId("current_location"),
            position: userLatLng,
            infoWindow: const InfoWindow(title: "موقعي الحالي"),
          ),
        );
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تعذر تحديد الموقع الحالي")),
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_googleMapController.isCompleted) {
      _googleMapController.complete(controller);
    }
    _mapController = controller;
    _updateUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              'إضافة عنوان جديد',
              style: AppTextStyles.heading20Bold.copyWith(
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0.00,
            backgroundColor: lightOrange,
            foregroundColor: Colors.white,
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
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            child: Form(
              key: _formKey,
              onChanged: _validateForm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 1.h),
                  SizedBox(
                    height: 40.h,
                    width: 100.w,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : (_initialCameraPosition == null
                              ? const Center(
                                  child: Text("تعذر تحديد الموقع الحالي"),
                                )
                              : GoogleMap(
                                  initialCameraPosition:
                                      _initialCameraPosition!,
                                  mapType: MapType.normal,
                                  myLocationButtonEnabled: true,
                                  myLocationEnabled: true,
                                  zoomControlsEnabled: true,
                                  zoomGesturesEnabled: true,
                                  markers: _markers,
                                  onMapCreated: _onMapCreated,
                                  onTap: (LatLng position) {
                                    setState(() {
                                      _pickedLocation = position;
                                      _markers.clear();
                                      _markers.add(
                                        Marker(
                                          markerId: const MarkerId(
                                            "picked_location",
                                          ),
                                          position: position,
                                          infoWindow: const InfoWindow(
                                            title: "الموقع المختار",
                                          ),
                                        ),
                                      );
                                    });
                                    _mapController?.animateCamera(
                                      CameraUpdate.newLatLng(position),
                                    );
                                  },
                                )),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: houseNumberController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'رقم المنزل',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال رقم المنزل';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: apartmentController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'الحي/الشارع/ رقم الشقة',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال تفاصيل العنوان';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),
                  DropdownButtonFormField2(
                    decoration: InputDecoration(
                      labelText: 'حفظ الموقع',
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    hint: const Text('اختر اسم الموقع'),
                    items: addressOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'الرجاء اختيار حفظ الموقع';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        selectedAddressTitle = value as String;
                      });
                      _validateForm();
                    },
                    value: selectedAddressTitle,
                    buttonStyleData: const ButtonStyleData(height: 60),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  ElevatedButton(
                    onPressed: !isButtonEnabled || registerButtonPressed
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() != true) {
                              return;
                            }
                            if (!mounted) return;
                            setState(() {
                              registerButtonPressed = true;
                            });

                            // Use the picked location if available, else get current location
                            LatLng? chosenLatLng;
                            if (_pickedLocation != null) {
                              chosenLatLng = _pickedLocation;
                            } else {
                              Position? location =
                                  await LocationServices.getCurrentLocation();
                              if (location == null) {
                                ToastService.sendScaffoldAlert(
                                  msg:
                                      "لم نتمكن من تحديد موقعك، الرجاء تفعيل خدمة الموقع.",
                                  toastStatus: "ERROR",
                                  context: context,
                                );
                                setState(() {
                                  registerButtonPressed = false;
                                });
                                return;
                              }
                              chosenLatLng = LatLng(
                                location.latitude,
                                location.longitude,
                              );
                            }

                            if (chosenLatLng == null) {
                              ToastService.sendScaffoldAlert(
                                msg:
                                    "الرجاء اختيار موقع على الخريطة أو السماح بتحديد موقعك الحالي",
                                toastStatus: "ERROR",
                                context: context,
                              );
                              setState(() {
                                registerButtonPressed = false;
                              });
                              return;
                            }

                            String addressID = uuid.v1().toString();
                            UserAddressModel addressData = UserAddressModel(
                              addressID: addressID,
                              userID: auth.currentUser!.uid,
                              latitude: chosenLatLng.latitude,
                              longitude: chosenLatLng.longitude,
                              roomNo: houseNumberController.text.trim(),
                              apartment: apartmentController.text.trim(),
                              addressTitle: selectedAddressTitle ?? '',
                              uploadTime: DateTime.now(),
                              isActive: false,
                            );

                            await UserDataCRUDServices.addAddress(
                              addressData,
                              context,
                            );

                            if (!mounted) return;
                            Navigator.pop(context);
                            context.read<ProfileProvider>().fetchUserAddress();

                            ToastService.sendScaffoldAlert(
                              msg: 'تم إضافة الموقع بنجاح',
                              toastStatus: 'SUCCESS',
                              context: context,
                            );
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
                    child: registerButtonPressed
                        ? CircularProgressIndicator(color: white)
                        : Text(
                            'حفظ الموقع',
                            style: AppTextStyles.body18.copyWith(color: white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
