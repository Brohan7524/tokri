import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class ManageFamilyScreen extends StatelessWidget {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  void showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFF4E6), // Pale Peach
        title: const Text(
          'Add Family Member',
          style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _customInput(nameController, 'Name'),
              _customInput(ageController, 'Age', isNumber: true),
              _customInput(heightController, 'Height (cm)', isNumber: true),
              _customInput(weightController, 'Weight (kg)', isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B4513))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF68B984), // Medium Green
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final uid = AuthService.currentUserId;
              if (uid == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User not logged in")),
                );
                return;
              }

              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Name is required")),
                );
                return;
              }

              final member = FamilyMember(
                id: '',
                name: nameController.text.trim(),
                age: int.tryParse(ageController.text) ?? 0,
                height: double.tryParse(heightController.text) ?? 0,
                weight: double.tryParse(weightController.text) ?? 0,
              );

              try {
                await FirestoreService.addFamilyMember(member);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Family member added")),
                );
                nameController.clear();
                ageController.clear();
                heightController.clear();
                weightController.clear();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to add member: $e")),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0), // Cream
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2D974), // Soft Yellow
        title: const Text(
          '👨‍👩‍👧‍👦 Manage Family',
          style: TextStyle(color: Color(0xFF2C3E50)),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<FamilyMember>>(
        stream: FirestoreService.getFamilyMembers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final family = snapshot.data!;
          if (family.isEmpty) {
            return const Center(
              child: Text(
                "No family members yet.",
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: family.length,
            itemBuilder: (_, index) {
              final member = family[index];
              return Card(
                color: const Color(0xFFFFF4E6),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(
                    member.name,
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "Age: ${member.age}, Height: ${member.height} cm, Weight: ${member.weight} kg",
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFF8B4513)), // Rust
                    onPressed: () => FirestoreService.deleteFamilyMember(member.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF68B984), // Medium Green
        foregroundColor: Colors.white,
        onPressed: () => showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _customInput(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
