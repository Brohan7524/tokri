import 'package:flutter/material.dart';
import '../models/family_member.dart';
import 'weekly_plan_screen.dart'; // for CombinedWeeklyPlanScreen

class FamilyMemberDetailScreen extends StatelessWidget {
  final FamilyMember member;

  const FamilyMemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${member.name}'s Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👤 Name: ${member.name}", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text("🎂 Age: ${member.age} years"),
            Text("📏 Height: ${member.height} cm"),
            Text("⚖️ Weight: ${member.weight} kg"),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: const Text("View Weekly Plan"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CombinedWeeklyPlanScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Generate Nutrition Plan (Mock)"),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🍎 AI model will be integrated here.")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
