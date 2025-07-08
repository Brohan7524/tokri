import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUserId;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0), // Cream
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2D974), // Soft Yellow
        elevation: 0,
        title: const Text(
          "📦 Order History",
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("orders")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("❌ Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No past orders found.",
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final order = docs[index];
              final timestamp = (order['timestamp'] as Timestamp).toDate();
              final formattedDate = DateFormat('EEE, MMM d • hh:mm a').format(timestamp);

              final items = List<Map<String, dynamic>>.from(order['items']);
              final memberName = order['family_member_name'] ?? 'Unknown';
              final totalPrice = order['total_price'] ?? 0;
              final status = order['status'] ?? 'Pending';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6), // Pale Peach
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🕒 $formattedDate",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          fontSize: 16,
                        )),
                    const SizedBox(height: 4),
                    Text("👤 For: $memberName", style: const TextStyle(color: Color(0xFF6B7280))),
                    Text("💰 Total: ₹$totalPrice", style: const TextStyle(color: Color(0xFF6B7280))),
                    Text("📦 Status: $status", style: const TextStyle(color: Color(0xFF6B7280))),
                    const SizedBox(height: 10),
                    const Text(
                      "🛒 Items:",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 6),
                    ...items.map((item) {
                      final name = item['name'] ?? '';
                      final quantity = item['quantity'] ?? 1;
                      return Row(
                        children: [
                          const Icon(Icons.arrow_right, size: 18, color: Color(0xFF8B4513)),
                          const SizedBox(width: 4),
                          Text("$name × $quantity", style: const TextStyle(color: Color(0xFF2C3E50))),
                        ],
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
