
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String name;
  final String imageUrl;
  final String time;
  final String difficulty;
  final String category;
  final List<String> ingredients;
  final List<String> steps;
  final String createdBy;
  final DateTime createdAt;

  RecipeModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.createdBy,
    required this.createdAt,
  });

  factory RecipeModel.fromMap(Map<String, dynamic> map, String id) {
    return RecipeModel(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      time: map['time'] ?? '',
      difficulty: map['difficulty'] ?? '',
      category: map['category'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'time': time,
      'difficulty': difficulty,
      'category': category,
      'ingredients': ingredients,
      'steps': steps,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}