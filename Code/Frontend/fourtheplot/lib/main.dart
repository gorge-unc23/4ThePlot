import 'package:flutter/material.dart';
import 'package:fourtheplot/pages/landing/landing_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4ThePlot',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        textTheme: TextTheme(
          bodySmall: TextStyle(
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
          ),
          headlineLarge: TextStyle(
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
          ),
          headlineSmall: TextStyle(
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            color: Colors.white,
          ),
        ),
        appBarTheme: AppBarThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.blueAccent.withValues(alpha: 0.2)),
            foregroundColor: WidgetStatePropertyAll(Colors.white)
          ),
        ),
        // scaffoldBackgroundColor: const Color.fromARGB(255, 29, 27, 27)
        scaffoldBackgroundColor: const Color(0xFF0F1012),
      ),
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.blue),
      ),
      home: const LandingPage(),
    );
  }
}
