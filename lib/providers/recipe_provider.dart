
import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../repositories/recipe_repository.dart';

enum LoadingState { loading, success, error }

class RecipeProvider with ChangeNotifier {
  LoadingState _state = LoadingState.loading;
  List<RecipeModel> _recipes = [];
  String _errorMessage = '';
  final RecipeRepository _repo = RecipeRepository();

  // Геттери
  LoadingState get state => _state;
  List<RecipeModel> get recipes => _recipes;
  String get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadingState.loading;
  bool get hasError => _state == LoadingState.error;

  RecipeProvider() {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    _state = LoadingState.loading;
    notifyListeners();

    try {
      _recipes = await _repo.getRecipes();
      _state = LoadingState.success;
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Не вдалося завантажити рецепти: $e';
    }
    notifyListeners();
  }

  Future<void> addRecipe(RecipeModel recipe) async {
    try {
      await _repo.addRecipe(recipe);
      await loadRecipes(); // Оновлюємо список
    } catch (e) {
      _errorMessage = 'Помилка додавання: $e';
      notifyListeners();
    }
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    try {
      await _repo.updateRecipe(recipe);
      await loadRecipes();
    } catch (e) {
      _errorMessage = 'Помилка оновлення: $e';
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await _repo.deleteRecipe(id);
      await loadRecipes();
    } catch (e) {
      _errorMessage = 'Помилка видалення: $e';
      notifyListeners();
    }
  }
}