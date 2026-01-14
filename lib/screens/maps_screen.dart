import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class MapsScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapsScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final MapController _mapController = MapController();

  late LatLng _targetPosition;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _targetPosition = widget.initialLat != null && widget.initialLng != null
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : const LatLng(40.7128, -74.0060); // Nueva York por defecto
    _getCurrentLocation();
  }

  @override
  void dispose() {
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
        _userLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(_userLocation!, 15);
    } catch (e) {
      developer.log('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [
      Marker(
        point: _targetPosition,
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
    ];
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 50,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
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
              Icons.my_location,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      );
    }
    List<Polyline> polylines = _userLocation != null
        ? [
            Polyline(
              points: [_userLocation!, _targetPosition],
              color: Colors.red,
              strokeWidth: 4.0,
            ),
          ]
        : [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa con Ruta', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade900,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red, Colors.black],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _targetPosition,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  ),
                  MarkerLayer(
                    markers: markers,
                  ),
                  PolylineLayer(
                    polylines: polylines,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _getCurrentLocation,
        icon: const Icon(Icons.my_location, color: Colors.white),
        label: const Text('Mi ubicación', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade900,
        elevation: 8,
      ),
    );
  }
}