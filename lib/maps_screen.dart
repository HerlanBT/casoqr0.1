import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  LatLng _currentPosition = const LatLng(40.7128, -74.0060); // Nueva York por defecto

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // El usuario negó el permiso
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // El usuario negó permanentemente el permiso
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _latController.text = position.latitude.toStringAsFixed(6);
        _lngController.text = position.longitude.toStringAsFixed(6);
      });

      _mapController.move(_currentPosition, 15);
    } catch (e) {
      developer.log('Error getting location: $e');
    }
  }

  void _updatePositionFromInputs() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat != null && lng != null) {
      setState(() {
        _currentPosition = LatLng(lat, lng);
      });
      _mapController.move(_currentPosition, 15);
    }
  }

  void _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      final coords = data.text!.split(',');
      if (coords.length == 2) {
        final lat = double.tryParse(coords[0].trim());
        final lng = double.tryParse(coords[1].trim());
        if (lat != null && lng != null) {
          setState(() {
            _currentPosition = LatLng(lat, lng);
            _latController.text = lat.toStringAsFixed(6);
            _lngController.text = lng.toStringAsFixed(6);
          });
          _mapController.move(_currentPosition, 15);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Interactivo'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Instrucciones'),
                  content: const Text(
                    'Toca en el mapa para seleccionar una ubicación.\n'
                    'Ingresa coordenadas y presiona Enter.\n'
                    'Usa el botón de pegar para coordenadas del portapapeles.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel de controles mejorado
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _latController,
                          decoration: InputDecoration(
                            labelText: 'Latitud',
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: 'Ej: 40.7128',
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.location_on, color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (_) => _updatePositionFromInputs(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _lngController,
                          decoration: InputDecoration(
                            labelText: 'Longitud',
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: 'Ej: -74.0060',
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.location_on, color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (_) => _updatePositionFromInputs(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.content_paste, color: Colors.white),
                        onPressed: _pasteFromClipboard,
                        tooltip: 'Pegar coordenadas',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _updatePositionFromInputs,
                          icon: const Icon(Icons.map),
                          label: const Text('Ir a coordenadas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Mapa
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition,
                  initialZoom: 15,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _currentPosition = point;
                      _latController.text = point.latitude.toStringAsFixed(6);
                      _lngController.text = point.longitude.toStringAsFixed(6);
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _getCurrentLocation,
        icon: const Icon(Icons.my_location),
        label: const Text('Mi ubicación'),
        backgroundColor: Colors.deepPurple,
        elevation: 8,
      ),
    );
  }
}