import 'dart:developer';

import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/services/pushNotificationServices/pushNotificationServices.dart';
import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/model/technicianModel/technicianModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({required this.service, super.key});

  final ServiceModel service;

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
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final auth = FirebaseAuth.instance;

                    // 1. Get current user ID
                    final userID = auth.currentUser?.uid;
                    if (userID == null) {
                      log('⚠️ No authenticated user found.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('المستخدم غير مسجل الدخول')),
                      );
                      return;
                    }
                    log('👤 Current user ID: $userID');

                    // 2. Generate a request ID
                    final requestID =
                        'REQ_${DateTime.now().millisecondsSinceEpoch}';
                    log('🆔 Generated request ID: $requestID');

                    // 3. Get technicians from Firebase
                    final techSnapshot = await FirebaseDatabase.instance
                        .ref('Technician')
                        .get();
                    List<TechnicianModel> allTechnicians = [];

                    if (techSnapshot.exists) {
                      final techMap = Map<String, dynamic>.from(
                        techSnapshot.value as Map,
                      );
                      allTechnicians = techMap.entries.map((entry) {
                        final map = Map<String, dynamic>.from(entry.value);
                        map['technicianID'] = entry.key;
                        return TechnicianModel.fromMap(map);
                      }).toList();
                      log(
                        '📋 Loaded ${allTechnicians.length} technicians from Firebase.',
                      );
                    } else {
                      log('⚠️ No technicians found in Firebase.');
                    }

                    // 4. Log all technicians with majors
                    for (var tech in allTechnicians) {
                      log(
                        '👷‍♂️ Technician: ${tech.name}, Major: ${tech.major}, Token: ${tech.cloudMessagingToken}',
                      );
                    }

                    // 5. Filter technicians by major
                    final filteredTechnicians = allTechnicians.where((tech) {
                      final major = tech.major?.trim();
                      final isMatch =
                          major != null && major == service.major.trim();

                      log(
                        '🔍 Comparing technician major "$major" with service "$service" => Match: $isMatch',
                      );
                      return isMatch;
                    }).toList();

                    log(
                      '✅ Filtered technicians count: ${filteredTechnicians.length}',
                    );

                    if (filteredTechnicians.isEmpty) {
                      log('❌ No technicians found with matching major.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('لا يوجد فنيون في التخصص المطلوب'),
                        ),
                      );
                      return;
                    }

                    // 6. Send notification to each matched technician
                    for (var technician in filteredTechnicians) {
                      final token = technician.cloudMessagingToken;
                      if (token != null && token.isNotEmpty) {
                        log(
                          '📨 Sending notification to ${technician.name} (token: $token)...',
                        );
                        await PushNotificationServices()
                            .sendNotificationToTechnician(
                              technicianToken: token,
                              serviceTitle: service.name,
                              serviceDescription: service.detail,
                            );
                      } else {
                        log(
                          '⚠️ Technician ${technician.name} has no token, skipping.',
                        );
                      }
                    }

                    // 7. Notify user
                    log('✅ All matching technicians have been notified.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم إرسال الإشعارات للفنيين المختصين'),
                      ),
                    );
                  } catch (e, stackTrace) {
                    log('❗ Failed to send push notification: $e\n$stackTrace');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ في إرسال الإشعار')),
                    );
                  }
                },

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
