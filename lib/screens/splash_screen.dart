import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'home_screen.dart';
import '../admin/dashboard_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<Widget> handleUserRedirection(User user) async {
    final uid = user.uid;
    final email = user.email ?? '';

    if (email == 'admin@tokri.com') {
      return const DashboardScreen(); // Quick shortcut
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final docSnap = await docRef.get();

    // 🔧 If user doc doesn't exist, create it (safe fallback)
    if (!docSnap.exists) {
      await docRef.set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    final userData = (await docRef.get()).data() ?? {};
    final isAdmin = userData['isAdmin'] ?? false;

    if (isAdmin == true) {
      await FirebaseAuth.instance.signOut(); // Block admin
      return const LoginScreen();
    }

    return const HomeScreen(); // Valid normal user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF68B984)));
          }

          final user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }

          return FutureBuilder<Widget>(
            future: handleUserRedirection(user),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF68B984)));
              } else if (futureSnapshot.hasError) {
                return Center(child: Text('⚠️ Error: ${futureSnapshot.error}'));
              } else {
                return futureSnapshot.data!;
              }
            },
          );
        },
      ),
    );
  }
}
