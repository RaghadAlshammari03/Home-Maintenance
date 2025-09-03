import 'dart:developer';

import 'package:baligny/constant/constant.dart';
import 'package:baligny/model/servicesModel/servicesModel.dart';

class ServicesService {
  ServicesService();

  Future<List<ServiceModel>> getServicesByType(String type) async {
    try {
      final snap = await firestore.collection('Services').where('type', isEqualTo: type).get();
      return snap.docs
          .map((d) {
            final map = Map<String, dynamic>.from(d.data());
            map['serviceID'] = d.id;
            return ServiceModel.fromMap(map);
          })
          .toList();
    } catch (e, st) {
      log('ServicesService.getServicesByType error: $e\n$st');
      return [];
    }
  }
}
