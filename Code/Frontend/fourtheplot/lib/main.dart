import 'package:flutter/material.dart';
import 'package:fourtheplot/app_theme_controller.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/pages/landing/landing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.loadServerIp();
  await AppThemeController.instance.load();

  runApp(MyApp(themeController: AppThemeController.instance));
}

class MyApp extends StatelessWidget {
  final AppThemeController themeController;

  const MyApp({super.key, required this.themeController});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: '4ThePlot',
          debugShowCheckedModeBanner: false,
          themeMode: themeController.themeMode,
          darkTheme: _darkTheme(),
          theme: _lightTheme(),
          home: const LandingPage(),
        );
      },
    );
  }

  ThemeData _darkTheme() {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF6EA8FF),
      secondary: Color(0xFF9B6CFF),
      surface: Color(0xFF151B33),
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      cardColor: const Color(0xFF1A1B1F),
      scaffoldBackgroundColor: const Color(0xFF0F1012),
      dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF191B1F)),
      appBarTheme: const AppBarThemeData(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1B1F),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white70,
        textColor: Colors.white,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(
            Colors.blueAccent.withValues(alpha: 0.2),
          ),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
        ),
      ),
      textTheme: const TextTheme(
        bodySmall: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        headlineLarge: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
      ),
    );
  }

  ThemeData _lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
      primary: const Color(0xFF2563EB),
      secondary: const Color(0xFF7C3AED),
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      cardColor: Colors.white,
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
      appBarTheme: const AppBarThemeData(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Color(0xFF4B5563)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFF4B5563),
        textColor: Color(0xFF111827),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(
            Colors.blueAccent.withValues(alpha: 0.12),
          ),
          foregroundColor: const WidgetStatePropertyAll(Color(0xFF111827)),
        ),
      ),
      textTheme: const TextTheme(
        bodySmall: TextStyle(color: Color(0xFF111827)),
        bodyMedium: TextStyle(color: Color(0xFF111827)),
        bodyLarge: TextStyle(color: Color(0xFF111827)),
        headlineLarge: TextStyle(color: Color(0xFF111827)),
        headlineMedium: TextStyle(color: Color(0xFF111827)),
        headlineSmall: TextStyle(color: Color(0xFF111827)),
        titleMedium: TextStyle(color: Color(0xFF111827)),
      ),
    );
  }
}
