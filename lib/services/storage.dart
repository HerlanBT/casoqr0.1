import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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