import 'package:bel_sekolah/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bel_sekolah/views/SplashScreen.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'NoInternetApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (FirebaseAuth.instance.currentUser != null) {
    await initializeDateFormatting('id_ID', null)
        .then((_) => runApp(const MyApp()));
  } else {
    try {
      await FirebaseAuth.instance.signInAnonymously().timeout(const Duration(seconds: 10));
      await initializeDateFormatting('id_ID', null).then((_) => runApp(const MyApp()));
    } catch (e) {
      print('Error signing in anonymously: $e');
      runApp(const NoInternetApp(errorMessage: 'Koneksi dengan server gagal.\nSilakan coba lagi.'));
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
