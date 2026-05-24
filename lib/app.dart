import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/game_screen.dart';
import 'screens/shop_screen.dart';

class ZeusBoltDashApp extends StatelessWidget {
  const ZeusBoltDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zeus Bolt Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0520),
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (_) => const LoadingScreen(),
        '/menu': (_) => const MenuScreen(),
        '/game': (_) => const GameScreen(),
        '/shop': (_) => const ShopScreen(),
      },
    );
  }
}
