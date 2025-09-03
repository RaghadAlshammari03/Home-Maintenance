import 'dart:async';
import 'dart:convert';

import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../controller/provider/technician_tracking_provider.dart';
import '../../../controller/provider/review_provider.dart';
import '../../../model/serviceOrderModel/serviceOrderModel.dart';
import '../../../utils/colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:baligny/widgets/toastService.dart'; // added for toast
import 'package:geolocator/geolocator.dart';
import 'package:baligny/view/basketScreen/basketScreen.dart';
import 'package:baligny/utils/order_status_utils.dart';
import 'package:baligny/widgets/service_card_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TrackTechnicianScreen extends StatefulWidget {
  final String orderId;

  const TrackTechnicianScreen({Key? key, required this.orderId})
    : super(key: key);

  @override
  State<TrackTechnicianScreen> createState() => _TrackTechnicianScreenState();
}

class _TrackTechnicianScreenState extends State<TrackTechnicianScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  late final DatabaseReference databaseReference;
  DatabaseReference? _technicianLocRef;
  StreamSubscription<DatabaseEvent>? _techLocSub;

  bool _completionHandled = false; // ensure pop+toast only once

  DateTime? _lastCameraAnimateAt;
  LatLng? _lastCameraTarget;
  static const Duration _cameraMinInterval = Duration(seconds: 4);
  static const double _cameraMinMoveMeters =
      8; // min distance before camera animates

  Future<void> _callTechnician(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      ToastService.sendScaffoldAlert(
        msg: 'رقم الهاتف غير متوفر',
        toastStatus: 'ERROR',
        context: context,
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ToastService.sendScaffoldAlert(
          msg: 'تعذر إجراء المكالمة',
          toastStatus: 'ERROR',
          context: context,
        );
      }
    } catch (e) {
      ToastService.sendScaffoldAlert(
        msg: 'خطأ أثناء محاولة الاتصال',
        toastStatus: 'ERROR',
        context: context,
      );
    }
  }

  int _statusIndex(String status) {
    final c = normalizeToCanonical(status);
    if (c == STATUS_DELIVERED) return 3;
    if (c == STATUS_ON_THE_WAY) return 2;
    if (c == STATUS_ACCEPTED) return 1;
    return 0; // preparation or unknown
  }

  Widget _buildStatusProgress(String status) {
    // Arabic labels and improved alignment under icons
    final steps = [
      {'label': 'تم إنشاء الطلب', 'icon': Icons.receipt_long},
      {'label': 'تم قبول الطلب', 'icon': Icons.task_alt},
      {'label': 'الفني في الطريق', 'icon': Icons.delivery_dining},
      {'label': 'تم التنفيذ', 'icon': Icons.verified},
    ];
    final idx = _statusIndex(status);

    Color active = darkBlue;
    Color inactive = Colors.grey.shade300;
    Color textActive = Colors.black87;
    Color textInactive = Colors.black45;

    // Force the progress to render left-to-right regardless of screen direction
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stepCount = steps.length;
            final iconSize = 36.0;
            final gapCount = stepCount - 1;
            final availableForGaps =
                constraints.maxWidth - (stepCount * iconSize);
            final double gapWidth = gapCount > 0
                ? availableForGaps / gapCount
                : 0.0;
            // Make the connector line shorter than the original computed gap
            final double connectorWidth = gapCount > 0 ? gapWidth * 0.8 : 0.0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icons with connecting bars
                Row(
                  children: [
                    for (int i = 0; i < stepCount; i++) ...[
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: (i <= idx)
                              ? active.withOpacity(0.12)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (i <= idx) ? active : inactive,
                            width: 2,
                          ),
                          boxShadow: [
                            if (i <= idx)
                              BoxShadow(
                                color: active.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Icon(
                          steps[i]['icon'] as IconData,
                          size: 20,
                          color: (i <= idx) ? active : Colors.grey,
                        ),
                      ),
                      if (i < stepCount - 1)
                        Container(
                          width: connectorWidth,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: (i < idx) ? active : inactive,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ],
                ),
                SizedBox(height: 0.8.h),
                // Labels perfectly aligned under icons using same spacing math
                SizedBox(
                  width: constraints.maxWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < stepCount; i++) ...[
                        SizedBox(
                          width: iconSize,
                          child: Text(
                            steps[i]['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: (i <= idx)
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: (i <= idx) ? textActive : textInactive,
                            ),
                          ),
                        ),
                        if (i < stepCount - 1)
                          SizedBox(
                            width: connectorWidth + 12.0,
                          ), // match shorter bar + its horizontal margins
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Listen directly to the order using orderId
    databaseReference = FirebaseDatabase.instance.ref().child(
      'Orders/${widget.orderId}',
    );
    debugPrint('Firebase Path (Order): Orders/${widget.orderId}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delivery status will be updated by order stream
    });
  }

  @override
  void dispose() {
    _techLocSub?.cancel();
    // Clear provider state when leaving the screen
    try {
      context.read<TechnicianProvider>().clearRouteData();
    } catch (_) {}
    super.dispose();
  }

  void _ensureTechnicianLocationListener(
    ServiceOrderModel order,
    TechnicianProvider provider,
  ) {
    final techId = order.technicianUID ?? order.technicianData?.technicianID;
    if (techId == null || techId.isEmpty) {
      debugPrint(
        'No technician ID found on order; skipping location listener.',
      );
      return;
    }

    // If already listening to same tech, do nothing
    final currentPath = _technicianLocRef?.path;
    final desiredPath = 'Technician/$techId/location';
    if (currentPath != null && currentPath.toString().endsWith(desiredPath)) {
      return;
    }

    _techLocSub?.cancel();
    _technicianLocRef = FirebaseDatabase.instance.ref().child(desiredPath);
    debugPrint('Firebase Path (Technician Location): $desiredPath');

    _techLocSub = _technicianLocRef!.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null) {
        debugPrint('Technician location snapshot is null.');
        return;
      }
      try {
        final map = Map<String, dynamic>.from(jsonDecode(jsonEncode(value)));
        final lat = (map['latitude'] as num?)?.toDouble();
        final lng = (map['longitude'] as num?)?.toDouble();
        if (lat == null || lng == null) {
          debugPrint('Technician location missing latitude/longitude keys.');
          return;
        }
        // Heading keys can vary depending on publisher
        double? heading =
            (map['heading'] ?? map['bearing'] ?? map['course']) is num
            ? (map['heading'] ?? map['bearing'] ?? map['course']).toDouble()
            : null;
        if (heading != null) {
          // Normalize heading 0-360
          heading = heading % 360;
          if (heading < 0) heading += 360;
        }
        double? speed = (map['speed'] is num)
            ? (map['speed'] as num).toDouble()
            : null; // expect m/s

        final latLng = LatLng(lat, lng);
        provider.updateTechnicianPose(
          position: latLng,
          heading: heading,
          speed: speed,
        );

        if (provider.inDelivery) {
          provider.updateMarker(context);

          // Throttle camera animation to avoid jitter
          _mapController.future.then((controller) async {
            try {
              final now = DateTime.now();
              bool shouldAnimate = false;
              if (_lastCameraAnimateAt == null || _lastCameraTarget == null) {
                shouldAnimate = true;
              } else {
                final elapsed = now.difference(_lastCameraAnimateAt!);
                final moved = Geolocator.distanceBetween(
                  latLng.latitude,
                  latLng.longitude,
                  _lastCameraTarget!.latitude,
                  _lastCameraTarget!.longitude,
                );
                if (elapsed >= _cameraMinInterval ||
                    moved >= _cameraMinMoveMeters) {
                  shouldAnimate = true;
                }
              }
              if (shouldAnimate) {
                double zoom = 16.0;
                try {
                  zoom = await controller.getZoomLevel();
                } catch (_) {}
                await controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: latLng,
                      zoom: zoom,
                      bearing: (heading ?? 0).toDouble(),
                      tilt: 0,
                    ),
                  ),
                );
                _lastCameraAnimateAt = now;
                _lastCameraTarget = latLng;
              }
            } catch (e) {
              debugPrint('Camera animation error: $e');
            }
          });
        }
      } catch (e) {
        debugPrint('Failed to parse technician location: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String _formatUpdateTime(DateTime? dt) {
      if (dt == null) return '';
      final local = dt.toLocal();
      final now = DateTime.now();
      final twoDigits = (int n) => n.toString().padLeft(2, '0');
      final timePart = '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
      if (local.year == now.year &&
          local.month == now.month &&
          local.day == now.day) {
        return timePart; // same day -> show only time
      }
      return '${local.day}/${local.month}/${local.year} $timePart';
    }

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'تتبع الفني',
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
          body: StreamBuilder(
            stream: databaseReference.onValue,
            builder: (context, event) {
              if (event.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: black));
              }

              String status = '';

              if (event.hasData && event.data!.snapshot.value != null) {
                final raw = event.data!.snapshot.value;
                debugPrint('Raw Order Snapshot: $raw');

                Map<String, dynamic>? orderMap;
                if (raw is Map) {
                  if (raw.containsKey('orderID')) {
                    orderMap = Map<String, dynamic>.from(
                      jsonDecode(jsonEncode(raw)),
                    );
                  } else if (raw.containsKey(widget.orderId)) {
                    orderMap = Map<String, dynamic>.from(
                      jsonDecode(jsonEncode(raw[widget.orderId])),
                    );
                  }
                }

                if (orderMap != null) {
                  if (orderMap['userUID'] == null &&
                      orderMap['userData'] is Map &&
                      (orderMap['userData']['userID'] != null)) {
                    orderMap['userUID'] = orderMap['userData']['userID'];
                  }

                  try {
                    final parsed = ServiceOrderModel.fromMap(orderMap);
                    debugPrint('Parsed ServiceOrderData for ${parsed.orderID}');

                    status = parsed.orderStatus ?? '';
                    // Preserve previous behavior: consider ACCEPTED and ON_THE_WAY as 'in-delivery' for provider
                    final norm = normalizeToCanonical(status);
                    final onTheWay =
                        (norm == STATUS_ON_THE_WAY) ||
                        (norm == STATUS_ACCEPTED);

                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      final provider = context.read<TechnicianProvider>();
                      provider.updateOrderData(parsed);
                      provider.updateInDeliveryStatus(onTheWay);
                      _ensureTechnicianLocationListener(parsed, provider);
                      if (onTheWay) {
                        provider.updateMarker(context);
                      }

                      // Debug logging to help diagnose why the completion dialog may not show
                      debugPrint(
                        'Order ${parsed.orderID} status raw="$status" canonical="${normalizeToCanonical(status)}" deliveredAt=${parsed.orderDeliveredAt}',
                      );

                      // Auto-pop only once when reaching delivered status.
                      // Only treat as delivered when the backend status is exactly 'SERVICE_DONE'
                      // (case-insensitive) or when the status text contains 'complete' (case-insensitive).
                      final String statusUpper = status.trim().toUpperCase();
                      final String statusLower = status.toLowerCase();
                      final bool isDeliveredByStatus =
                          statusUpper == 'SERVICE_DONE' ||
                          statusLower.contains('complete');

                      if (isDeliveredByStatus) {
                        debugPrint(
                          'Treating order ${parsed.orderID} as DELIVERED by status match (raw="$status").',
                        );
                      }

                      if (isDeliveredByStatus &&
                          mounted &&
                          !_completionHandled) {
                        _completionHandled = true;
                        _techLocSub?.cancel();

                        // Before popping, show a dialog that allows the user to add a review.
                        final reviewsProvider = context.read<ReviewsProvider>();
                        final nameController = TextEditingController();
                        final textController = TextEditingController();
                        double rating = 5.0;
                        bool _showInlineSuccess = false;

                        await showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogCtx) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                bool isSubmitting = false;
                                return Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: AlertDialog(
                                    title: const Text('تم اكتمال الطلب'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'تم اكتمال الطلب. يمكنك إضافة تقييم الآن',
                                            textAlign: TextAlign.right,
                                          ),
                                          SizedBox(height: 8),
                                          TextField(
                                            controller: nameController,
                                            textDirection: TextDirection.rtl,
                                            decoration: const InputDecoration(
                                              labelText: 'الاسم',
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          TextField(
                                            controller: textController,
                                            textDirection: TextDirection.rtl,
                                            maxLines: 4,
                                            decoration: const InputDecoration(
                                              labelText: 'نص التعليق',
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text('التقييم:'),
                                          ),
                                          RatingBar.builder(
                                            initialRating: rating,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 28.0,
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (r) {
                                              setState(() {
                                                rating = r;
                                              });
                                            },
                                          ),
                                          if (isSubmitting) ...[
                                            SizedBox(height: 12),
                                            Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ],
                                          if (_showInlineSuccess) ...[
                                            SizedBox(height: 12),
                                            Text(
                                              'تم إرسال رأيك',
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('تخطي'),
                                        onPressed: isSubmitting
                                            ? null
                                            : () {
                                                try {
                                                  Navigator.of(
                                                    dialogCtx,
                                                  ).pop(false);
                                                } catch (_) {}
                                              },
                                      ),
                                      ElevatedButton(
                                        child: isSubmitting
                                            ? SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Text('إرسال'),
                                        onPressed: isSubmitting
                                            ? null
                                            : () async {
                                                final name = nameController.text
                                                    .trim();
                                                final text = textController.text
                                                    .trim();
                                                if (name.isEmpty ||
                                                    text.isEmpty) {
                                                  try {
                                                    ScaffoldMessenger.of(
                                                      dialogCtx,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'يرجى ملء جميع الحقول',
                                                        ),
                                                      ),
                                                    );
                                                  } catch (_) {}
                                                  return;
                                                }

                                                // optimistic local update (attach orderID)
                                                reviewsProvider.addReview(
                                                  name: name,
                                                  rating: rating,
                                                  text: text,
                                                  orderID:
                                                      parsed.orderID ??
                                                      widget.orderId,
                                                );

                                                setState(() {
                                                  isSubmitting = true;
                                                });

                                                try {
                                                  await reviewsProvider
                                                      .addReviewPersist(
                                                        name: name,
                                                        rating: rating,
                                                        text: text,
                                                        orderID:
                                                            parsed.orderID ??
                                                            widget.orderId,
                                                      );

                                                  // show inline success and close dialog after short delay
                                                  setState(() {
                                                    _showInlineSuccess = true;
                                                  });
                                                  await Future.delayed(
                                                    const Duration(
                                                      milliseconds: 600,
                                                    ),
                                                  );
                                                  try {
                                                    Navigator.of(
                                                      dialogCtx,
                                                    ).pop(true);
                                                  } catch (_) {}
                                                } catch (e) {
                                                  setState(() {
                                                    isSubmitting = false;
                                                  });
                                                  try {
                                                    ScaffoldMessenger.of(
                                                      dialogCtx,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'فشل إرسال الرأي. حاول لاحقًا',
                                                        ),
                                                      ),
                                                    );
                                                  } catch (_) {}
                                                }
                                              },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );

                        // If user skipped or after submit, navigate back to BasketScreen
                        if (!mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const BasketScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    });
                  } catch (e, s) {
                    debugPrint('Failed to parse ServiceOrderModel: $e');
                    debugPrint(s.toString());
                  }
                }
              }

              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 1.h),

                    // Map card first
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Consumer<TechnicianProvider>(
                            builder: (context, provider, child) {
                              if (provider.technicianLocation == null) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Stack(
                                children: [
                                  GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: provider.technicianLocation!,
                                      zoom: 14.0,
                                    ),
                                    markers: provider.deliveryMarker,
                                    polylines:
                                        provider.polylineSetTowardsCustomer,
                                    onMapCreated: (controller) {
                                      if (!_mapController.isCompleted) {
                                        _mapController.complete(controller);
                                      }
                                    },
                                    // Ensure gestures work when map is inside a scrollable
                                    gestureRecognizers:
                                        <Factory<OneSequenceGestureRecognizer>>{
                                          Factory<OneSequenceGestureRecognizer>(
                                            () => EagerGestureRecognizer(),
                                          ),
                                        },
                                    myLocationEnabled: false,
                                    zoomControlsEnabled: false,
                                    mapToolbarEnabled: false,
                                    tiltGesturesEnabled: true,
                                    rotateGesturesEnabled: true,
                                    zoomGesturesEnabled: true,
                                    scrollGesturesEnabled: true,
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    right: 8,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            provider.routeDurationText ?? '',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            provider.routeDistanceText ?? '',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 1.5.h),

                    // Progress under the map (as requested)
                    _buildStatusProgress(status),

                    SizedBox(height: 1.5.h),

                    // Details card below progress
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Consumer<TechnicianProvider>(
                          builder: (context, provider, child) {
                            final order = provider.orderData;
                            final techName =
                                order?.technicianData?.name ?? 'الفني';
                            // Support multi-service orders
                            final services = order?.servicesOrPrimary ?? [];

                            // Aggregate duplicates (by serviceID or name) and sum quantities
                            List<ServiceModel> displayServices = [];
                            if (services.isNotEmpty) {
                              final Map<String, ServiceModel> agg = {};
                              for (final s in services) {
                                final key =
                                    (s.serviceID?.trim().isNotEmpty == true)
                                    ? s.serviceID!
                                    : (s.name ?? '');

                                if (agg.containsKey(key)) {
                                  agg[key]!.quantity =
                                      (agg[key]!.quantity ?? 0) +
                                      (s.quantity ?? 1);
                                } else {
                                  agg[key] = ServiceModel(
                                    serviceID: s.serviceID ?? '',
                                    name: s.name ?? '',
                                    detail: s.detail ?? '',
                                    major: s.major ?? '',
                                    type: s.type ?? '',
                                    quantity: s.quantity ?? 1,
                                    addedToCartAt: s.addedToCartAt,
                                    orderID: s.orderID,
                                  );
                                }
                              }
                              displayServices = agg.values.toList();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: darkBlue.withOpacity(
                                        0.12,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: darkBlue,
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Text(
                                        techName,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    // Show last update time if available
                                    if (provider.technicianLastUpdate != null)
                                      Text(
                                        'آخر تحديث: ${_formatUpdateTime(provider.technicianLastUpdate)}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    // Make phone icon tappable if phone number exists
                                    Builder(
                                      builder: (ctx) {
                                        final phone =
                                            order?.technicianData?.mobileNumber;
                                        return IconButton(
                                          icon: Icon(
                                            Icons.phone,
                                            color: darkBlue,
                                          ),
                                          onPressed:
                                              (phone != null &&
                                                  phone.trim().isNotEmpty)
                                              ? () => _callTechnician(phone)
                                              : null,
                                          tooltip:
                                              phone != null &&
                                                  phone.trim().isNotEmpty
                                              ? 'اتصال بالفني'
                                              : 'رقم غير متوفر',
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                SizedBox(height: 1.6.h),
                                Divider(height: 1, color: Colors.grey.shade200),
                                SizedBox(height: 1.6.h),

                                if (displayServices.isEmpty) ...[
                                  Text(
                                    'لا توجد خدمات',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ] else ...[
                                  // Use compact ServiceCardWidget for each aggregated service
                                  Column(
                                    children: displayServices
                                        .map(
                                          (svc) => ServiceCardWidget(
                                            service: svc,
                                            compact: true,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
