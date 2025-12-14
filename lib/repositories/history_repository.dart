
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Додати в історію
  Future<void> addToHistory(Map<String, dynamic> recipe) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = _db
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .doc(recipe['id'] ?? recipe['name']);

    await ref.set({
      ...recipe,
      'viewedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Отримати історію
  Future<List<Map<String, dynamic>>> getHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('viewedAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}