import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'firebase_options.dart';
import 'providers/scoring_provider.dart';
import 'providers/match_provider.dart';
import 'screens/home_screen.dart'; // Kita akan buat ini nanti

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    // WRAPPER PROVIDER: Agar state bisa mengalir ke seluruh aplikasi
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => ScoringProvider()),
      ],
      child: const KurashUsulApp(),
    ),
  );
}

class KurashUsulApp extends StatelessWidget {
  const KurashUsulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uzul Scoring',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // Ganti home sementara ke HomeScreen (akan dibuat di bawah)
      home: const HomeScreen(),
    );
  }
}