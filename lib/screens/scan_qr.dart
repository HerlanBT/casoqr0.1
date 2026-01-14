import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:el_caso_qr/services/storage.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  String? _scanResult;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    final Barcode? barcode = barcodes.firstOrNull;

    if (barcode != null && barcode.rawValue != null && _isScanning) {
      print('Código QR escaneado: ${barcode.rawValue}');
      setState(() {
        _isScanning = false;
        _scanResult = barcode.rawValue!;
      });

      // Mostrar resultado y permitir escanear de nuevo
      _showResultDialog(barcode.rawValue!);
    }
  }

  void _showResultDialog(String result) {
    print('QR Scan Result: $result');
    Map<String, dynamic>? parsedJson;
    try {
      parsedJson = json.decode(result);
      // Guardar en historia si es JSON válido
      addToHistoria(parsedJson!);
    } catch (e) {
      parsedJson = null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Código QR Escaneado'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (parsedJson != null) ...[
                  const Text('Datos del QR:'),
                  const SizedBox(height: 8),
                  if (parsedJson['titulo'] != null) ...[
                    const Text('Título:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(parsedJson['titulo']),
                    const SizedBox(height: 8),
                  ],
                  if (parsedJson['texto1'] != null) ...[
                    const Text('Texto 1:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(parsedJson['texto1']),
                    const SizedBox(height: 8),
                  ],
                  if (parsedJson['texto2'] != null) ...[
                    const Text('Texto 2:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(parsedJson['texto2']),
                    const SizedBox(height: 8),
                  ],
                  if (parsedJson['coordenadas'] != null) ...[
                    const Text('Coordenadas:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Lat: ${parsedJson['coordenadas']['lat']}, Lng: ${parsedJson['coordenadas']['lng']}'),
                    const SizedBox(height: 8),
                  ],
                ] else ...[
                  const Text('Resultado:'),
                  const SizedBox(height: 8),
                  Text(
                    result,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/');
              },
              child: const Text('Aceptar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/historia');
              },
              child: const Text('Ir a Historia'),
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
        title: const Text('Escanear Código QR'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () async {
              await cameraController.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
              color: Colors.white,
            ),
            onPressed: () async {
              await cameraController.switchCamera();
              setState(() {
                _isFrontCamera = !_isFrontCamera;
              });
            },
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          // Overlay con marco de escaneo
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Coloca el código QR aquí',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          // Instrucciones en la parte inferior
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Alinea el código QR dentro del marco blanco para escanearlo automáticamente.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Indicador de escaneo
          if (_scanResult != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Escaneado: ${_scanResult!.length > 50 ? '${_scanResult!.substring(0, 50)}...' : _scanResult!}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
