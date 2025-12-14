// pages/history_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../models/recipe_model.dart';
import 'recipe_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Історія', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7F3), Color(0xFFFFE8E1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<HistoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }
            if (provider.history.isEmpty) {
              return const Center(
                child: Text(
                  'Історія порожня\nВи ще не переглядали рецепти',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.history.length,
              itemBuilder: (ctx, i) {
                final item = provider.history[i];
                final String name = item['name']?.toString() ?? 'Без назви';
                final String imageUrl = item['imageUrl']?.toString() ?? '';
                final String time = item['time']?.toString() ?? '—';
                final String date = _formatDate(item['viewedAt']);

                return _historyCard(context, name, imageUrl, time, date, item);
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '—';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return 'Сьогодні';
      } else if (diff.inDays == 1) {
        return 'Вчора';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} днів тому';
      } else {
        return '${date.day}.${date.month}.${date.year}';
      }
    }
    return '—';
  }

  Widget _historyCard(BuildContext context, String name, String imageUrl, String time, String date, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        final recipe = RecipeModel(
          id: item['id'] ?? '',
          name: name,
          imageUrl: imageUrl,
          time: time,
          difficulty: item['difficulty'] ?? 'Легко',
          category: item['category'] ?? 'Інше',
          ingredients: List<String>.from(item['ingredients'] ?? []),
          steps: List<String>.from(item['steps'] ?? []),
          createdBy: item['createdBy'] ?? '',
          createdAt: DateTime.now(),
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported),
                ),
              )
                  : Container(width: 70, height: 70, color: Colors.grey.shade200, child: const Icon(Icons.no_photography)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(time, style: TextStyle(color: Colors.orange.shade700, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}