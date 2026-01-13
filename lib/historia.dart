import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

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
            colors: [Colors.deepPurple, Colors.purpleAccent],
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
                          colors: [Colors.white, Color(0xFFFAFAFA)],
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
                                const Icon(Icons.book, color: Colors.deepPurple),
                                const SizedBox(width: 8),
                                Text(
                                  parte['titulo'] ?? 'Parte ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (parte['texto1'] != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.text_fields, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  const Text('Texto 1:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(parte['texto1'], style: const TextStyle(fontSize: 16)),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (parte['texto2'] != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.text_fields, color: Colors.green),
                                  const SizedBox(width: 8),
                                  const Text('Texto 2:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(parte['texto2'], style: const TextStyle(fontSize: 16)),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (parte['coordenadas'] != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.red),
                                  const SizedBox(width: 8),
                                  const Text('Coordenadas:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Lat: ${parte['coordenadas']['lat']}, Lng: ${parte['coordenadas']['lng']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    String lat = parte['coordenadas']['lat'];
                                    String lng = parte['coordenadas']['lng'];
                                    await Clipboard.setData(ClipboardData(text: '$lat,$lng'));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Coordenadas copiadas al portapapeles'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copiar Coordenadas'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
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
