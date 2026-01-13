import 'package:flutter/material.dart';
import 'package:el_caso_qr/holamundo.dart';
import 'package:el_caso_qr/homescreen.dart';
import 'package:el_caso_qr/scanqr.dart';
import 'package:el_caso_qr/maps_screen.dart';
import 'package:el_caso_qr/historia.dart';
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
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