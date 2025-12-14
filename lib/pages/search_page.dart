// pages/search_page.dart
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
   SearchPage({Key? key}) : super(key: key);

  final List<String> popular = ['Шоколадний торт', 'Домашня піца', 'Суп з грибами', 'Млинці', 'Вареники', 'Тірамісу'];
  final List<String> recent = ['Паста Болоньєзе', 'Грецький салат', 'Чізкейк'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Пошук рецептів', style: TextStyle(color: Colors.black87)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Пошуковий рядок
            TextField(
              decoration: InputDecoration(
                hintText: 'Знайти рецепт в Інтернеті...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),

            // Популярні запити
            const Text('Популярні запити', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: popular.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: Colors.orange.shade50,
                labelStyle: TextStyle(color: Colors.orange.shade800),
              )).toList(),
            ),
            const SizedBox(height: 30),

            // Останні пошуки
            const Text('Останні пошуки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...recent.map((item) => ListTile(
              leading: const Icon(Icons.access_time, color: Colors.grey),
              title: Text(item),
              onTap: () {},
            )),
          ],
        ),
      ),
    );
  }
}