import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final String technicianID = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference ref = FirebaseDatabase.instance.ref(
      'Technician/$technicianID/Orders',
    );

    final DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final loadedOrders = data.entries.map((entry) {
        return {
          'requestID': entry.key,
          ...Map<String, dynamic>.from(entry.value),
        };
      }).toList();

      setState(() {
        orders = loadedOrders;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text('الطلبات')),
          body: orders.isEmpty
              ? Center(child: Text('لا توجد طلبات'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(order['serviceName'] ?? 'بدون اسم'),
                        subtitle: Text('الحالة: ${order['status']}'),
                        trailing: order['status'] == 'pending'
                            ? ElevatedButton(
                                onPressed: () async {
                                  final String technicianID =
                                      FirebaseAuth.instance.currentUser!.uid;
        
                                  await FirebaseDatabase.instance
                                      .ref(
                                        'Technician/$technicianID/Orders/${order['requestID']}/status',
                                      )
                                      .set('accepted');
        
                                  fetchOrders();
                                },
                                child: Text('قبول'),
                              )
                            : Text('تم القبول'),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
