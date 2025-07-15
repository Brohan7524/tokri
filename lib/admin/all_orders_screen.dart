import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  List<Map<String, dynamic>> allOrders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAllOrders();
  }

  Future<void> fetchAllOrders() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    List<Map<String, dynamic>> ordersList = [];

    for (var userDoc in usersSnapshot.docs) {
      final ordersSnapshot = await userDoc.reference.collection('orders').get();

      for (var order in ordersSnapshot.docs) {
        final data = order.data();

        ordersList.add({
          "userId": userDoc.id,
          "userName": userDoc.data()['name'] ?? 'Unknown',
          "orderId": order.id,
          "timestamp": data['timestamp'],
          "items": data['items'],
          "total_price": data['total_price'],
          "total_calories": data['total_calories'],
          "status": data['status'] ?? 'Pending',
          "family_member": data['family_member_name'] ?? 'N/A',
          "reference": order.reference,
        });
      }
    }

    ordersList.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

    setState(() {
      allOrders = ordersList;
      loading = false;
    });
  }

  Future<void> exportOrdersToCSV(BuildContext context) async {
    List<List<String>> rows = [
      ['UserID', 'Member Name', 'Items', 'Total Price', 'Calories', 'Status', 'Timestamp']
    ];

    for (var order in allOrders) {
      final items = (order['items'] as List)
          .map((e) => '${e['name']} x${e['quantity']}')
          .join('; ');
      final timestamp = (order['timestamp'] as Timestamp).toDate().toIso8601String();

      rows.add([
        order['userId'],
        order['family_member'] ?? '',
        items,
        order['total_price'].toString(),
        order['total_calories'].toString(),
        order['status'] ?? '',
        timestamp,
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);

    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Storage permission denied")),
      );
      return;
    }

    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/order_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ CSV saved to: ${file.path}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2D974),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
        title: const Text(
          "📦 All Orders",
          style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () => exportOrdersToCSV(context),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allOrders.length,
        itemBuilder: (_, index) {
          final order = allOrders[index];
          final status = order['status'] ?? 'Pending';
          final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
          final memberName = order['family_member'] ?? 'Unknown';
          final timestamp = (order['timestamp'] as Timestamp).toDate();
          final formattedDate = DateFormat('MMM d, yyyy hh:mm a').format(timestamp);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E6),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("👤 $memberName",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50))),
                const SizedBox(height: 4),
                Text("🕒 $formattedDate", style: const TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(height: 10),
                ...items.map((item) => Text(
                  "• ${item['name']} x${item['quantity']} (${item['calories']} cal)",
                  style: const TextStyle(fontSize: 14),
                )),
                const SizedBox(height: 10),
                Text(
                  "💰 ₹${order['total_price']} | 🔥 ${order['total_calories']} cal",
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF2C3E50)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Status: "),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'Delivered' ? Colors.green[100] : Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == 'Delivered' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (status != 'Delivered')
                      TextButton.icon(
                        onPressed: () async {
                          await order['reference'].update({"status": "Delivered"});
                          fetchAllOrders();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("✅ Marked as Delivered")),
                            );
                          }
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text("Mark Delivered"),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF68B984),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
