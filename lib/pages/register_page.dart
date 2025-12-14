import 'package:cooking_book/main.dart';
import 'package:cooking_book/pages/home_page.dart';
import 'package:cooking_book/widgets/black_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/input_card.dart';
import '../theme/app_colors.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController passConfirmController = TextEditingController();

  bool loading = false;

  // pages/register_page.dart (тільки частина з _registerUser)
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      // Оновлюємо ім'я (опціонально)
      await FirebaseAuth.instance.currentUser?.updateDisplayName(nameController.text);

      // ПЕРЕХІД НА ГОЛОВНИЙ ЕКРАН
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigator()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = '';
      if (e.code == 'email-already-in-use') errorMsg = 'Ця пошта вже використовується';
      else errorMsg = e.message ?? 'Помилка реєстрації';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final double sidePadding = 28;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7F3), Color(0xFFFFF1F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _headerIcon(),
                  const SizedBox(height: 18),
                  const Text('Створити акаунт',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Почніть зберігати свої улюблені рецепти',
                      style: TextStyle(color: AppColors.subtleText)),
                  const SizedBox(height: 20),

                  _buildTextField(
                    label: 'Ім’я',
                    controller: nameController,
                    hint: 'Введіть ваше ім’я',
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Введіть ім’я' : null,
                  ),

                  _buildTextField(
                    label: 'Електронна пошта',
                    controller: emailController,
                    hint: 'example@email.com',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Введіть електронну пошту';
                      if (!value.contains('@')) return 'Введіть коректну електронну пошту';
                      return null;
                    },
                  ),

                  _buildTextField(
                    label: 'Пароль',
                    controller: passController,
                    hint: 'Введіть пароль',
                    obscure: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Введіть пароль';
                      if (value.length < 6) return 'Пароль має містити мінімум 6 символів';
                      return null;
                    },
                  ),

                  _buildTextField(
                    label: 'Підтвердження паролю',
                    controller: passConfirmController,
                    hint: 'Повторіть пароль',
                    obscure: true,
                    validator: (value) {
                      if (value != passController.text) return 'Паролі не співпадають';
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),
                  BlackButton(
                    text: loading ? 'Зачекайте...' : 'Зареєструватися',
                    onPressed: loading ? null : () async => await _registerUser(),
                  ),

                  const SizedBox(height: 18),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Вже маєте акаунт? ', style: TextStyle(color: AppColors.subtleText)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Увійти',
                          style: TextStyle(
                              color: AppColors.gradientEnd, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset('assets/images/image_logo.png', fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return InputCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: AppColors.subtleText, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ]),
    );
  }
}
