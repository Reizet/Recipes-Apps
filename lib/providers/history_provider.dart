
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class HistoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> addToHistory(Map<String, dynamic> recipeData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .doc(recipeData['id']);

    await ref.set({
      ...recipeData,
      'viewedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await loadHistory();
  }

  // Завантажуємо історію, сортуємо за viewedAt (найновіші зверху)
  Future<void> loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _history = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .orderBy('viewedAt', descending: true)
          .limit(50)
          .get();

      _history = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _error = null;
    } catch (e) {
      _error = 'Не вдалося завантажити історію';
      print('History error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}