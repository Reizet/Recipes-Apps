// main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/history_page.dart';
import 'pages/recipe_detail_page.dart';
import 'pages/add_recipe_page.dart';
import 'pages/search_page.dart';
import 'pages/shopping_list_page.dart';
import 'providers/history_provider.dart';
import 'theme/app_colors.dart';
import 'providers/recipe_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CookingBookApp());
}

class CookingBookApp extends StatelessWidget {
  const CookingBookApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: MaterialApp(
        title: 'Кулінарна книга',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          scaffoldBackgroundColor: AppColors.bg,
          fontFamily: 'Sans',
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (_) => LoginPage(),
          '/register': (_) => RegisterPage(),
        },
      ),
    );
  }
}

// Автоматичний вхід
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          // Завантажуємо історію при вході
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<HistoryProvider>().loadHistory();
          });
          return const MainNavigator();
        }
        return LoginPage();
      },
    );
  }
}

// Головний екран з нижньою навігацією
class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 2; // Головна

  // Сторінки для швидкого перемикання
  static final List<Widget> _pages = [
    const ShoppingListPage(),     // 0 — Покупки
    const ShoppingListPage(),     // 1 — дубль (бо 0 використовується для історії)
     const HomePage(),             // 2 — Головна
    const AddRecipePage(),        // 3 — Додати
     SearchPage(),           // 4 — Пошук
  ];

  void _onTabTapped(int index) {
    if (index == 0) {
      // Історія — окремий екран
      Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage()));
    } else if (index == 1) {
      setState(() => _currentIndex = 0); // Покупки
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecipePage()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) =>  SearchPage()));
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.access_time, 'Історія', 0),
                _navItem(Icons.shopping_cart_outlined, 'Покупки', 1),
                _navItem(Icons.home, 'Головна', 2),
                _navItem(Icons.add_circle_outline, 'Додати', 3),
                _navItem(Icons.search, 'Пошук', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isActive = _currentIndex == index || (index == 1 && _currentIndex == 0);
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.gradientStart : Colors.grey[600],
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.gradientStart : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}