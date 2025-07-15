import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_member.dart';
import 'auth_service.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String? get _uid => AuthService.currentUserId;

  static CollectionReference get _familyCollection {
    if (_uid == null) throw Exception("User not logged in");
    return _db.collection('users').doc(_uid).collection('family');
  }

  static Stream<List<FamilyMember>> getFamilyMembers() {
    return _familyCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FamilyMember.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  static Future<void> addFamilyMember(FamilyMember member) async {
    await _familyCollection.add({
      'name': member.name,
      'age': member.age,
      'height': member.height,
      'weight': member.weight,
      'gender': member.gender,
      'activityLevel': member.activityLevel,
    });
  }

  static Future<void> deleteFamilyMember(String id) async {
    await _familyCollection.doc(id).delete();
  }
}
