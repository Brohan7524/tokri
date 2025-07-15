import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchUsersWithFamily() async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userDocs = await userCollection.get();
    List<Map<String, dynamic>> userList = [];

    for (var userDoc in userDocs.docs) {
      final userId = userDoc.id;
      final email = userDoc.data()['email'] ?? 'N/A';

      final familySnap = await userDoc.reference.collection('family').get();
      final familyMembers = familySnap.docs.map((doc) => doc.data()).toList();

      userList.add({
        'uid': userId,
        'email': email,
        'family': familyMembers,
      });
    }

    return userList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0), // Cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2D974), // Soft Yellow
        elevation: 0,
        title: const Text(
          "👥 Users & Families",
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUsersWithFamily(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)),
            );
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(
              child: Text("No users found.", style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (_, index) {
              final user = users[index];
              final uid = user['uid'];
              final email = user['email'];
              final family = user['family'] as List;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
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
                    Text("📧 Email: $email",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        )),
                    const SizedBox(height: 4),
                    Text("🔑 UID: $uid", style: const TextStyle(color: Color(0xFF6B7280))),
                    const SizedBox(height: 12),
                    const Text(
                      "👨‍👩‍👧 Family Members:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (family.isEmpty)
                      const Text(
                        "No members added.",
                        style: TextStyle(color: Color(0xFF6B7280)),
                      )
                    else
                      ...family.map((member) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "• ${member['name']} (Age: ${member['age']}, H: ${member['height']} cm, W: ${member['weight']} kg)",
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                      )),
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
