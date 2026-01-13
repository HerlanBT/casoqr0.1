import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  LatLng _currentPosition = const LatLng(40.7128, -74.0060); // Nueva York por defecto
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _mapController?.dispose();
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
        _updateMarker(_currentPosition);
        _latController.text = position.latitude.toStringAsFixed(6);
        _lngController.text = position.longitude.toStringAsFixed(6);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );
    } catch (e) {
      // Error al obtener la ubicación
      developer.log('Error getting location: $e');
    }
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Ubicación seleccionada',
            snippet: '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          ),
        ),
      };
    });
  }

  void _goToCoordinates() {
    try {
      double lat = double.parse(_latController.text);
      double lng = double.parse(_lngController.text);

      // Validar rangos de coordenadas
      if (lat < -90 || lat > 90) {
        _showErrorDialog('La latitud debe estar entre -90 y 90');
        return;
      }
      if (lng < -180 || lng > 180) {
        _showErrorDialog('La longitud debe estar entre -180 y 180');
        return;
      }

      LatLng newPosition = LatLng(lat, lng);
      setState(() {
        _currentPosition = newPosition;
        _updateMarker(newPosition);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newPosition, 15),
      );
    } catch (e) {
      _showErrorDialog('Por favor ingresa coordenadas válidas');
    }
  }

  void _pasteCoordinates() async {
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null) {
        String text = data.text!.trim();

        // Intentar diferentes formatos de coordenadas
        RegExp coordPattern = RegExp(r'(-?\d+\.?\d*),\s*(-?\d+\.?\d*)');
        Match? match = coordPattern.firstMatch(text);

        if (match != null) {
          double lat = double.parse(match.group(1)!);
          double lng = double.parse(match.group(2)!);

          _latController.text = lat.toStringAsFixed(6);
          _lngController.text = lng.toStringAsFixed(6);
          _goToCoordinates();
        } else {
          _showErrorDialog('Formato de coordenadas no reconocido. Usa el formato: latitud, longitud');
        }
      }
    } catch (e) {
      _showErrorDialog('Error al pegar las coordenadas');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Coordenadas'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: _getCurrentLocation,
            tooltip: 'Mi ubicación',
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel de entrada de coordenadas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.deepPurple, Colors.purpleAccent],
              ),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white54, width: 1),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _lngController,
                        decoration: InputDecoration(
                          labelText: 'Longitud',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Ej: -74.0060',
                          hintStyle: const TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white54, width: 1),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _goToCoordinates,
                        icon: const Icon(Icons.map),
                        label: const Text('Ir a coordenadas'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pasteCoordinates,
                        icon: const Icon(Icons.content_paste),
                        label: const Text('Pegar coordenadas'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Mapa
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              onTap: (LatLng position) {
                setState(() {
                  _currentPosition = position;
                  _latController.text = position.latitude.toStringAsFixed(6);
                  _lngController.text = position.longitude.toStringAsFixed(6);
                  _updateMarker(position);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
