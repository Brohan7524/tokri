import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../models/family_member.dart';
import '../screens/family_member_detail_screen.dart';

class FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final Map<String, double> vitamins;
  final VoidCallback onViewDetails;

  const FamilyMemberCard({
    super.key,
    required this.member,
    required this.vitamins,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: Colors.orangeAccent),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("${member.age} y", style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FamilyMemberDetailScreen(member: member),
                    ),
                  );
                },
                child: const Text("View Details"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text("Recommended Meals: Loading...", style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Row(children: [
            _infoBox("${_estimateCalories(member)} kcal", "Calories", Colors.orange),
            const SizedBox(width: 12),
            _infoBox("${_estimateProtein(member)} g", "Protein", Colors.amber),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            PieChart(
              dataMap: vitamins,
              chartRadius: 50,
              legendOptions: const LegendOptions(showLegends: false),
              chartValuesOptions: const ChartValuesOptions(showChartValues: false),
            ),
            PieChart(
              dataMap: vitamins,
              chartRadius: 50,
              legendOptions: const LegendOptions(showLegends: false),
              chartValuesOptions: const ChartValuesOptions(showChartValues: false),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _infoBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ]),
    );
  }

  int _estimateCalories(FamilyMember m) => (m.weight * 30).toInt();
  int _estimateProtein(FamilyMember m) => (m.weight * 1.2).toInt();
}
