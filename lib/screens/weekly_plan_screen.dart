import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';

class CombinedWeeklyPlanScreen extends StatefulWidget {
  const CombinedWeeklyPlanScreen({super.key});

  @override
  State<CombinedWeeklyPlanScreen> createState() => _CombinedWeeklyPlanScreenState();
}

class _CombinedWeeklyPlanScreenState extends State<CombinedWeeklyPlanScreen> {
  final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  String selectedDay = 'Monday';

  Map<String, List<String>> weeklyPlan = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final members = await FirestoreService.getFamilyMembers().first;
      final familySize = members.length;

      final basket = await fetchWeeklyBasket(familySize); // API call

      Map<String, List<String>> plan = {};
      for (int i = 0; i < basket.length; i++) {
        final dayData = basket[i];
        final String dayName = daysOfWeek[i % 7]; // Map Day 1 -> Monday, etc.

        List<String> meals = [];

        // Parse key meal components
        final breakfast = dayData['breakfast'];
        final lunch = dayData['lunch'];
        final snack = dayData['snack'];
        final dinner = dayData['dinner'];
        final ingredients = dayData['cooking_ingredients'];

        meals.add("🍓 Breakfast: Fruits - ${breakfast?['fruits']?.join(', ') ?? 'N/A'}");
        if (breakfast?['sprouts'] != null) {
          meals.add("🥗 Sprouts: ${breakfast['sprouts']}");
        }

        meals.add("🍛 Lunch: Veggies - ${lunch?['vegetables']?.join(', ') ?? 'N/A'}");
        if (lunch?['pulse'] != null) meals.add("🍲 Pulse: ${lunch['pulse']}");

        meals.add("🍎 Snack: ${snack?['fruit'] ?? 'N/A'}");

        meals.add("🌙 Dinner: Veggies - ${dinner?['vegetables']?.join(', ') ?? 'N/A'}");
        if (dinner?['pulse'] != null) meals.add("🍲 Pulse: ${dinner['pulse']}");

        meals.add("🧄 Cooking Items: ${ingredients?.join(', ') ?? 'N/A'}");

        plan[dayName] = meals;
      }

      setState(() {
        weeklyPlan = plan;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final meals = weeklyPlan[selectedDay] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0), // Cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2D974), // Soft Yellow
        elevation: 0,
        title: const Text(
          "🍽️ Combined Weekly Plan",
          style: TextStyle(
            color: Color(0xFF2C3E50), // Dark Charcoal
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📅 Select a day:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFA8D5BA)), // Light green border
              ),
              child: DropdownButton<String>(
                value: selectedDay,
                underline: const SizedBox(),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
                onChanged: (value) {
                  if (value != null) setState(() => selectedDay = value);
                },
                items: daysOfWeek.map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "🍛 Meals for $selectedDay",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513), // Brown/Rust
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (_, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E6), // Pale Peach
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF68B984)), // Medium green
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            meals[index],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
