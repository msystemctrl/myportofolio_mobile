import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/app_colors.dart';
import 'package:myportofolio_mobile/menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.ink,
          primary: AppColors.ink,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
        ),
        // Latar halaman memakai warna krem yang sama dengan situs web.
        scaffoldBackgroundColor: AppColors.paper,
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}
