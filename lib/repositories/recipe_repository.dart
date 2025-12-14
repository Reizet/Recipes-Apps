
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _collection = FirebaseFirestore.instance.collection('recipes');

  Future<List<RecipeModel>> getRecipes() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => RecipeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<String> addRecipe(RecipeModel recipe) async {
    final docRef = await _collection.add(recipe.toMap());
    return docRef.id;
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    await _collection.doc(recipe.id).update(recipe.toMap());
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _collection.doc(recipeId).delete();
  }
}