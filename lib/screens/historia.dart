import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:el_caso_qr/screens/historia_detalle.dart';
import 'package:el_caso_qr/screens/maps_screen.dart';

class HistoriaScreen extends StatefulWidget {
  const HistoriaScreen({super.key});

  @override
  State<HistoriaScreen> createState() => _HistoriaScreenState();
}

class _HistoriaScreenState extends State<HistoriaScreen> {
  List<Map<String, dynamic>> _historia = [];

  @override
  void initState() {
    super.initState();
    _loadHistoria();
  }

  Future<void> _loadHistoria() async {
    final prefs = await SharedPreferences.getInstance();
    final historiaJson = prefs.getStringList('historia') ?? [];
    setState(() {
      _historia = historiaJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _clearHistoria() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('historia');
    setState(() {
      _historia = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: _clearHistoria,
            tooltip: 'Borrar historia',            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red, Colors.black],
          ),
        ),
        child: _historia.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 80, color: Colors.white70),
                    SizedBox(height: 16),
                    Text(
                      'No hay historia guardada aún.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _historia.length,
                itemBuilder: (context, index) {
                  final parte = _historia[index];
                  return Card(
                    elevation: 8,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Colors.black, Color(0xFF333333)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.book, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  parte['titulo'] ?? 'Parte ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (parte['texto1'] != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.text_fields, color: Colors.white),
                                  const SizedBox(width: 8),
                                  const Text('Texto 1:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade900,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(parte['texto1'], style: const TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (parte['texto2'] != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.text_fields, color: Colors.green),
                                  const SizedBox(width: 8),
                                  const Text('Texto 2:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade900,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(parte['texto2'], style: const TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (parte['coordenadas'] != null) ...[
                              // Botón Ver en Mapa
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    double lat = double.parse(parte['coordenadas']['lat'].toString());
                                    double lng = double.parse(parte['coordenadas']['lng'].toString());
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapsScreen(initialLat: lat, initialLng: lng),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.map),
                                  label: const Text('Ver en Mapa'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Botón Ver Historia
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HistoriaDetalleScreen(parte: parte),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.visibility),
                                  label: const Text('Ver Historia'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// Función para agregar una nueva parte a la historia
Future<void> addToHistoria(Map<String, dynamic> nuevaParte) async {
  final prefs = await SharedPreferences.getInstance();
  final historiaJson = prefs.getStringList('historia') ?? [];
  final historia = historiaJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();

  // Agregar título como "Parte X"
  nuevaParte['titulo'] = 'Parte ${historia.length + 1}';

  historia.add(nuevaParte);
  final nuevaHistoriaJson = historia.map((parte) => jsonEncode(parte)).toList();
  await prefs.setStringList('historia', nuevaHistoriaJson);
}
