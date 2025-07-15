import 'package:flutter/material.dart';
import '../models/family_member.dart';
import 'weekly_plan_screen.dart'; // for CombinedWeeklyPlanScreen

class FamilyMemberDetailScreen extends StatelessWidget {
  final FamilyMember member;

  const FamilyMemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0), // Cream
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2D974), // Soft Yellow
        elevation: 0,
        title: Text(
          "${member.name}'s Profile",
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E6), // Pale Peach
            borderRadius: BorderRadius.circular(16),
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
              Text(
                "👤 Name: ${member.name}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF2C3E50),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "🎂 Age: ${member.age} years",
                style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 6),
              Text(
                "📏 Height: ${member.height} cm",
                style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 6),
              Text(
                "⚖️ Weight: ${member.weight} kg",
                style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: const Text("View Weekly Plan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF68B984), // Medium Green
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CombinedWeeklyPlanScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
