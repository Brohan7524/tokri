import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import 'item_management_screen.dart'; // or manage_items_screen.dart
import 'all_orders_screen.dart';
import 'user_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalUsers = 0;
  int totalOrders = 0;
  int totalRevenue = 0;
  int pendingOrders = 0;
  int deliveredOrders = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() => loading = true);

    final userSnap = await FirebaseFirestore.instance.collection('users').get();
    final userDocs = userSnap.docs.where((doc) => (doc.data()['isAdmin'] ?? false) == false).toList();
    totalUsers = userDocs.length;

    int orders = 0;
    int revenue = 0;
    int pending = 0;
    int delivered = 0;

    for (var user in userDocs) {
      final orderSnap = await user.reference.collection('orders').get();
      for (var order in orderSnap.docs) {
        orders++;
        revenue += (order['total_price'] ?? 0) as int;

        final status = order['status'] ?? 'Pending';
        if (status == 'Pending') pending++;
        if (status == 'Delivered') delivered++;
      }
    }

    setState(() {
      totalOrders = orders;
      totalRevenue = revenue;
      pendingOrders = pending;
      deliveredOrders = delivered;
      loading = false;
    });
  }

  void navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget statCard(String title, int value, Color color, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 22,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget pieChart() {
    final total = pendingOrders + deliveredOrders;
    if (total == 0) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        height: 220,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                color: const Color(0xFFFFA726),
                value: pendingOrders.toDouble(),
                title: '$pendingOrders\nPending',
                radius: 60,
                titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
              ),
              PieChartSectionData(
                color: const Color(0xFF4DB6AC),
                value: deliveredOrders.toDouble(),
                title: '$deliveredOrders\nDelivered',
                radius: 60,
                titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
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
          "📊 Admin Dashboard",
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchStats,
            tooltip: "Refresh Stats",
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFFDF8F0),
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFFFF4E6)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "🛒 Tokri Admin",
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text("Manage Items"),
              onTap: () {
                Navigator.pop(context);
                navigateTo(const ItemManagementScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("All Orders"),
              onTap: () {
                Navigator.pop(context);
                navigateTo(const AllOrdersScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_alt),
              title: const Text("Manage Users"),
              onTap: () {
                Navigator.pop(context);
                navigateTo(const UserListScreen());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 12),
          statCard("👥 Total Users", totalUsers, const Color(0xFF2C3E50), Icons.people, () {}),
          statCard("🛍️ Total Orders", totalOrders, const Color(0xFF8B4513), Icons.shopping_cart, () {
            navigateTo(const AllOrdersScreen());
          }),
          statCard("💰 Total Revenue (₹)", totalRevenue, const Color(0xFF68B984), Icons.attach_money, () {}),
          statCard("⏳ Pending Orders", pendingOrders, const Color(0xFFFFA726), Icons.hourglass_top, () {
            navigateTo(const AllOrdersScreen());
          }),
          statCard("✅ Delivered Orders", deliveredOrders, const Color(0xFF4DB6AC), Icons.check_circle, () {
            navigateTo(const AllOrdersScreen());
          }),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "📦 Order Status Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          const SizedBox(height: 8),
          pieChart(),
        ],
      ),
    );
  }
}
