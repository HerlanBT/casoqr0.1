import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class RGBScreen extends StatefulWidget {
  const RGBScreen({super.key});

  @override
  State<RGBScreen> createState() => _RGBScreenState();
}

class _RGBScreenState extends State<RGBScreen> {
  Color color = Colors.black;
  Timer? timer;
  bool running = true;

  @override
  void initState() {
    super.initState();
    startRGB();
  }

  void startRGB() {
    timer?.cancel(); // Cancel any existing timer
    timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) {
        setState(() {
          color = Color.fromARGB(
            255,
            Random().nextInt(256),
            Random().nextInt(256),
            Random().nextInt(256),
          );
        });
      }
    });

    // ⏱️ detener después de 10 segundos (opcional)
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void stopRGB() {
    timer?.cancel();
    running = false;
  }

  void toggle() {
    if (running) {
      stopRGB();
    } else {
      running = true;
      startRGB();
    }
    //Retornar a la pantalla anterior
    
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: color,
        child: const Center(
          child: Text(
            'Hola Mundo RGB',
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              //quitar las 2 rayas del texto 
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 3,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
