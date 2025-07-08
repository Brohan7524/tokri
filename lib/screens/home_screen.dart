import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/screens/weekly_plan_screen.dart';

import '../services/firestore_service.dart';
import '../models/family_member.dart';
import 'family_member_detail_screen.dart';
import 'todays_basket_screen.dart';
import 'manage_family_screen.dart';
import 'order_history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void navigate(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0), // Cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2D974), // Soft Yellow
        title: const Text(
          "🍎 Tokri",
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
        drawer: Drawer(
          backgroundColor: const Color(0xFFFDF8F0), // Cream background
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFF4E4BC), // Warm Beige
                  image: DecorationImage(
                    image: AssetImage('assets/images/tokri_banner.png'), // Optional: custom banner
                    fit: BoxFit.cover,
                    opacity: 0.2,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "🍎 Tokri Menu",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50), // Dark Charcoal
                    ),
                  ),
                ),
              ),
              _drawerItem(
                icon: Icons.dashboard,
                label: "Dashboard",
                onTap: () => Navigator.pop(context),
              ),
              _drawerItem(
                icon: Icons.group,
                label: "Manage Family",
                onTap: () => navigate(context, ManageFamilyScreen()),
              ),
              _drawerItem(
                icon: Icons.calendar_month,
                label: "Weekly Plan",
                onTap: () => navigate(context, const CombinedWeeklyPlanScreen()),
              ),
              _drawerItem(
                icon: Icons.shopping_basket,
                label: "Today's Basket",
                onTap: () => navigate(context, const TodaysBasketScreen()),
              ),
              _drawerItem(
                icon: Icons.history,
                label: "Order History",
                onTap: () => navigate(context, OrderHistoryScreen()),
              ),
              _drawerItem(
                icon: Icons.settings,
                label: "Settings",
                onTap: () => navigate(context, const SettingsScreen()),
              ),
            ],
          ),
        ),
      body: StreamBuilder<List<FamilyMember>>(
        stream: FirestoreService.getFamilyMembers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final family = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (family.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.group_outlined, size: 64, color: Color(0xFF6B7280)),
                          const SizedBox(height: 16),
                          const Text(
                            "No family members added yet.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ManageFamilyScreen()),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Add Family Member"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF68B984),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    "👨‍👩‍👧‍👦 Your Family Members",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: family.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final member = family[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E6), // Pale Peach
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFE8F3E8),
                                  child: Text(
                                    member.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                      Text(
                                        "Age: ${member.age} • Weight: ${member.weight} kg",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FamilyMemberDetailScreen(member: member),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "View Details",
                                    style: TextStyle(
                                      color: Color(0xFF8B4513),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF8B4513)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _infoBox("Calories", "2000 kcal", const Color(0xFFF4E4BC)),
                                _infoBox("Protein", "70 g", const Color(0xFFF2D974)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
                                _vitaminIndicator("Vitamins", Color(0xFFA8D5BA)),
                                _vitaminIndicator("Vitamins", Color(0xFF68B984)),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (family.isNotEmpty)
                Container(
                  color: const Color(0xFFFFB366), // Soft Orange
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.shopping_bag),
                          label: const Text("Today's Basket"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TodaysBasketScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF68B984),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CombinedWeeklyPlanScreen()),
                          );
                        },
                        child: const Icon(Icons.calendar_month),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA8D5BA),
                          foregroundColor: const Color(0xFF2C3E50),
                          padding: const EdgeInsets.all(16),
                          shape: const CircleBorder(),
                        ),
                      )
                    ],
                  ),
                ),
            ],
          );
        },
      ),

    );
  }
}

Widget _infoBox(String label, String value, Color bgColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    ),
  );
}

class _vitaminIndicator extends StatelessWidget {
  final String label;
  final Color color;

  const _vitaminIndicator(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 12,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

Widget _drawerItem({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  Color color = const Color(0xFF2C3E50), // Default: Dark Charcoal
}) {
  return ListTile(
    leading: Icon(icon, color: color),
    title: Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: color,
      ),
    ),
    onTap: onTap,
    horizontalTitleGap: 8,
  );
}
