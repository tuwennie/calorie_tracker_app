import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/home_screen.dart';

void main() async {
  // Flutter engine ve Firebase'in ayağa kalkması için şart olan başlatıcılar
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase başlatma hatası: $e");
  }

  runApp(const CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      debugShowCheckedModeBanner: false,
      
      // Şık Mor ve Pembe Tema Ayarları
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A), // Koyu Mor
          primary: const Color(0xFF9C27B0),   // Mor
          secondary: const Color(0xFFE91E63), // Pembe
          surface: const Color(0xFFF3E5F5),   // Çok açık lila arka plan
        ),
        
        // AppBar (Üst Panel) Tasarımı
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF4A148C),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Buton Tasarımları
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      // Uygulama açıldığında çalışacak ilk ekran
      home: const HomeScreen(),
    );
  }
}