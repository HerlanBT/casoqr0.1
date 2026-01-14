import 'package:flutter/material.dart';
import 'package:el_caso_qr/holamundo.dart';
import 'package:el_caso_qr/homescreen.dart';
import 'package:el_caso_qr/screens/scan_qr.dart';
import 'package:el_caso_qr/screens/maps_screen.dart';
import 'package:el_caso_qr/screens/historia.dart';
import 'package:el_caso_qr/desencriptar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'El Caso QR',
      theme: ThemeData(
        primaryColor: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.red,
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.redAccent,
          surface: Colors.black,
          background: Colors.black,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/rgb': (context) => const RGBScreen(),
        '/qr': (context) => const QRScannerScreen(),
        '/maps': (context) => const MapsScreen(),
        '/historia': (context) => const HistoriaScreen(),
        '/caesar': (context) => const CaesarCipherScreen(),
      },
    );
  }
}