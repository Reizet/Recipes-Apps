// pages/recipe_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/history_provider.dart';
import '../theme/app_colors.dart';

class RecipeDetailPage extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  @override
  void initState() {
    super.initState();

    // Додаємо рецепт в історію одразу після відкриття сторінки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HistoryProvider>(context, listen: false);

      // Формуємо дані рецепту у вигляді Map (так, як очікує HistoryProvider)
      final recipeData = {
        'id': widget.recipe.id,
        'name': widget.recipe.name,
        'imageUrl': widget.recipe.imageUrl,
        'time': widget.recipe.time,
        'difficulty': widget.recipe.difficulty,
        'category': widget.recipe.category,
        'ingredients': widget.recipe.ingredients,
        'steps': widget.recipe.steps,
        'createdBy': widget.recipe.createdBy,
        // createdAt не обов’язково передавати — він не використовується при додаванні в історію
      };

      provider.addToHistory(recipeData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7F3), Color(0xFFFFE8E1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.favorite_border, color: Colors.pink),
                    ),
                  ],
                ),
              ),

              // Фото рецепту
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.recipe.imageUrl.isNotEmpty
                    ? Image.network(
                  widget.recipe.imageUrl,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, obj, trace) => Container(
                    height: 240,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                  ),
                )
                    : Container(
                  height: 240,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.no_photography, size: 80, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),

              // Назва + теги
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _tag('${widget.recipe.time}', Icons.access_time),
                        const SizedBox(width: 12),
                        _tag(widget.recipe.difficulty, Icons.whatshot),
                        const SizedBox(width: 12),
                        _tag(widget.recipe.category, Icons.category),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Інгредієнти
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.list_alt, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Інгредієнти', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.recipe.ingredients.length,
                          itemBuilder: (ctx, i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(widget.recipe.ingredients[i], style: const TextStyle(fontSize: 16))),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.orange.shade700, fontSize: 13)),
        ],
      ),
    );
  }
}