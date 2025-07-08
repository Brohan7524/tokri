import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Stream<User?> get authState => _auth.authStateChanges();

  static String? get currentUserId => _auth.currentUser?.uid;

  static User? get currentUser => _auth.currentUser;

  static Future<User?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

}

