import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class TodaysBasketScreen extends StatefulWidget {
  const TodaysBasketScreen({super.key});

  @override
  State<TodaysBasketScreen> createState() => _TodaysBasketScreenState();
}

class _TodaysBasketScreenState extends State<TodaysBasketScreen> {
  List<Map<String, dynamic>> availableItems = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    generateBasket();
  }

  Future<void> generateBasket() async {
    setState(() => loading = true);
    try {
      final members = await FirestoreService.getFamilyMembers().first;
      final familySize = members.length;

      final basket = await ApiService.fetchWeeklyBasket(familySize);
      final today = basket[0];

      final Map<String, int> result = {};
      final List<Map<String, dynamic>> items = [];

      void addItem(String name, [int qty = 1]) {
        if (name.isNotEmpty) {
          result[name] = (result[name] ?? 0) + qty;
        }
      }

      for (var veg in today['lunch']['vegetables']) addItem(veg.toString());
      for (var veg in today['dinner']['vegetables']) addItem(veg.toString());
      if (today['lunch']['pulse'] != null) addItem(today['lunch']['pulse'].toString());
      if (today['dinner']['pulse'] != null) addItem(today['dinner']['pulse'].toString());
      if (today['breakfast']['sprouts'] != null) {
        String sproutName = today['breakfast']['sprouts'].toString().split(' (')[0];
        addItem(sproutName);
      }
      for (var ing in today['cooking_ingredients']) addItem(ing.toString());
      for (var fruit in today['breakfast']['fruits']) addItem(fruit.toString());
      addItem(today['snack']['fruit'].toString());

      result.forEach((name, qty) {
        items.add({
          'name': name,
          'quantity': qty,
          'calories': 100,
          'price': 10,
        });
      });

      setState(() {
        availableItems = items;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error generating basket: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to generate basket: $e")),
        );
      }
      setState(() => loading = false);
    }
  }

  Future<String?> promptForAddress(String? currentAddress) async {
    final controller = TextEditingController(text: currentAddress ?? '');
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter Delivery Address"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Flat no, Street, City, Pincode",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> placeOrder() async {
    final uid = AuthService.currentUserId;
    if (uid == null || availableItems.isEmpty) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final userSnapshot = await userDoc.get();
    String? savedAddress = userSnapshot.data()?['deliveryAddress'];

    final enteredAddress = await promptForAddress(savedAddress);

    if (enteredAddress == null || enteredAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Address is required")),
      );
      return;
    }

    await userDoc.set({'deliveryAddress': enteredAddress}, SetOptions(merge: true));

    final timestamp = DateTime.now();
    List<Map<String, dynamic>> items = [];
    int totalCalories = 0;
    int totalPrice = 0;

    for (var item in availableItems) {
      final name = item['name'].toString();
      final quantity = item['quantity'] as int;
      final calories = item['calories'] as int;
      final price = item['price'] as int;

      items.add({
        "name": name,
        "quantity": quantity,
        "calories": calories,
      });

      totalCalories += calories * quantity;
      totalPrice += price * quantity;
    }

    await userDoc.collection("orders").add({
      "timestamp": timestamp,
      "items": items,
      "total_price": totalPrice,
      "total_calories": totalCalories,
      "status": "Pending",
      "family_member_name": "Combined",
      "delivery_address": enteredAddress,
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Order placed successfully")),
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
        title: const Text(
          "🧺 Today's Basket",
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableItems.length,
              itemBuilder: (context, index) {
                final item = availableItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E6),
                    borderRadius: BorderRadius.circular(12),
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
                      const Icon(Icons.fastfood, color: Color(0xFF68B984)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              "Calories: ${item['calories']} kcal • ₹${item['price']}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA8D5BA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Qty: ${item['quantity']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
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
          Container(
            color: const Color(0xFFFFB366),
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: placeOrder,
              icon: const Icon(Icons.shopping_cart),
              label: const Text("Place Order"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF68B984),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
