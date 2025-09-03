import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../model/serviceOrderModel/serviceOrderModel.dart';

class OrderProvider extends ChangeNotifier {
  ServiceOrderModel? _currentOrder;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  ServiceOrderModel? get currentOrder => _currentOrder;

  Future<void> fetchCurrentOrder(String userId) async {
    try {
      debugPrint('Fetching current order for user: $userId');
      final snapshot = await _databaseRef
          .child('Orders')
          .orderByChild('userUID')
          .equalTo(userId)
          .limitToFirst(1)
          .get();
      if (snapshot.exists) {
        debugPrint('Order data found: ${snapshot.value}');
        final rawData = snapshot.value as Map<dynamic, dynamic>;
        final firstOrder = rawData.values.first;
        final orderMap =
            jsonDecode(jsonEncode(firstOrder)) as Map<String, dynamic>;
        _currentOrder = ServiceOrderModel.fromMap(orderMap);
        notifyListeners();
      } else {
        debugPrint('No current order found for user: $userId');
        _currentOrder = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching current order: $e');
    }
  }

  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }
}
