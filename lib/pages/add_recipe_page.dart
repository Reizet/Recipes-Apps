
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:cooking_book/services/storage_service.dart';
import '../theme/app_colors.dart';
import '../providers/recipe_provider.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({Key? key}) : super(key: key);

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  final _storageService = StorageService();
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Потрібно увійти в акаунт')),
      );
      return;
    }

    setState(() => _isLoading = true);
    String? imageUrl;

    try {
      if (_selectedImage != null) {
        imageUrl = await _storageService.uploadRecipeImage(
          imageFile: _selectedImage!,
          context: context,
        );
        if (imageUrl == null) {
          setState(() => _isLoading = false);
          return;
        }
      }


      await FirebaseFirestore.instance.collection('recipes').add({
        'name': _titleController.text.trim(),
        'time': _timeController.text.trim(),
        'difficulty': 'Легко',
        'category': 'Інше',
        'ingredients': _ingredientsController.text.trim().split('\n'),
        'instructions': _instructionsController.text.trim(),
        'imageUrl': imageUrl,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'userName': FirebaseAuth.instance.currentUser!.displayName ?? 'Анонім',
        'createdAt': FieldValue.serverTimestamp(),
        'likesi': 0,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Рецепт успішно додано!'),
          backgroundColor: Colors.green,
        ),
      );

      Provider.of<RecipeProvider>(context, listen: false).loadRecipes();

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Додати рецепт'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Фото
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: _selectedImage == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 50, color: Colors.grey[600]),
                      const SizedBox(height: 12),
                      Text(
                        'Натисніть, щоб додати фото',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Назва
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Назва рецепту',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.restaurant_menu),
                ),
                validator: (v) => v!.isEmpty ? 'Введіть назву' : null,
              ),
              const SizedBox(height: 16),

              // Час приготування
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Час приготування',
                  hintText: 'Наприклад: 30 хв',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.access_time, color: Colors.orange),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Вкажіть час' : null,
              ),
              const SizedBox(height: 16),

              // Інгредієнти
              TextFormField(
                controller: _ingredientsController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Інгредієнти (кожен з нового рядка)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.trim().isEmpty ? 'Додайте інгредієнти' : null,
              ),
              const SizedBox(height: 16),

              // Інструкція
              TextFormField(
                controller: _instructionsController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Інструкція приготування',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.trim().isEmpty ? 'Опишіть приготування' : null,
              ),
              const SizedBox(height: 32),

              // Кнопка збереження
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gradientStart,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Зберегти рецепт',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}