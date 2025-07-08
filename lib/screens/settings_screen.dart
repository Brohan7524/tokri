import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? 'Not Available';
    final createdAt = user?.metadata.creationTime;
    final joinedDate = createdAt != null
        ? "${createdAt.day}/${createdAt.month}/${createdAt.year}"
        : 'Unknown';

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0), // Cream
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2D974), // Soft Yellow
        title: const Text(
          '⚙️ Settings',
          style: TextStyle(color: Color(0xFF2C3E50)),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("👤 Account Info"),
          _infoTile("Email", email),
          _infoTile("Joined", joinedDate),
          const SizedBox(height: 20),
          _sectionTitle("🔧 Preferences"),
          SwitchListTile(
            title: const Text("Enable Notifications"),
            subtitle: const Text("Mock setting (not functional)"),
            activeColor: const Color(0xFF68B984),
            value: notificationsEnabled,
            onChanged: (val) {
              setState(() {
                notificationsEnabled = val;
              });
            },
          ),
          const SizedBox(height: 20),
          _sectionTitle("📞 Support"),
          ListTile(
            leading: const Icon(Icons.mail_outline, color: Color(0xFF8B4513)),
            title: const Text("Contact Support"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("📧 support@tokri.app")),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513), // Brown/Rust
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
      subtitle: Text(value, style: const TextStyle(color: Color(0xFF2C3E50))),
    );
  }
}
