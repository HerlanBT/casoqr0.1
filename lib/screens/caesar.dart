import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CaesarCipherScreen extends StatefulWidget {
  const CaesarCipherScreen({super.key});

  @override
  State<CaesarCipherScreen> createState() => _CaesarCipherScreenState();
}

class _CaesarCipherScreenState extends State<CaesarCipherScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _shiftController = TextEditingController(text: '3');
  int _shift = 3;
  bool _isEncrypting = true;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

  String _caesarCipher(String text, int shift, bool encrypt) {
    StringBuffer result = StringBuffer();
    int actualShift = encrypt ? shift : -shift;

    for (int i = 0; i < text.length; i++) {
      int charCode = text.codeUnitAt(i);

      // Letras mayúsculas (A-Z)
      if (charCode >= 65 && charCode <= 90) {
        int newChar = ((charCode - 65 + actualShift) % 26 + 26) % 26 + 65;
        result.writeCharCode(newChar);
      }
      // Letras minúsculas (a-z)
      else if (charCode >= 97 && charCode <= 122) {
        int newChar = ((charCode - 97 + actualShift) % 26 + 26) % 26 + 97;
        result.writeCharCode(newChar);
      }
      // Números y caracteres especiales se mantienen igual
      else {
        result.write(text[i]);
      }
    }

    return result.toString();
  }

  void _processCipher() {
    try {
      int shift = int.parse(_shiftController.text);
      if (shift < 0 || shift > 25) {
        _showError('El desplazamiento debe estar entre 0 y 25');
        return;
      }

      String result = _caesarCipher(_inputController.text, shift, _isEncrypting);
      setState(() {
        _outputController.text = result;
        _shift = shift;
      });
    } catch (e) {
      _showError('Por favor ingresa un número válido para el desplazamiento');
    }
  }

  void _swapTexts() {
    String temp = _inputController.text;
    setState(() {
      _inputController.text = _outputController.text;
      _outputController.text = temp;
      _isEncrypting = !_isEncrypting;
    });
  }

  void _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copiado al portapapeles'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al copiar. Verifica permisos y HTTPS.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cifrado César'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.purpleAccent],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Card de información
              Card(
                elevation: 8,
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Cifrado de Sustitución',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEncrypting
                            ? 'Modo: ENCRIPTACIÓN'
                            : 'Modo: DESENCRIPTACIÓN',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isEncrypting ? Colors.blue : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'El cifrado César desplaza cada letra un número fijo de posiciones en el alfabeto.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Control de desplazamiento
              Card(
                elevation: 8,
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.settings, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'Desplazamiento (0-25)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _shift.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _shiftController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            int? parsed = int.tryParse(value);
                            if (parsed != null && parsed >= 0 && parsed <= 25) {
                              setState(() {
                                _shift = parsed;
                              });
                            }
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Ingresa el desplazamiento',
                          labelStyle: const TextStyle(color: Colors.orange),
                          hintText: 'Ej: 3',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orange, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orange, width: 1),
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Texto de entrada
              Card(
                elevation: 8,
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.input, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Texto para ${_isEncrypting ? 'Encriptar' : 'Desencriptar'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _inputController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Ingresa el texto aquí...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 1),
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _processCipher,
                          icon: const Icon(Icons.send),
                          label: Text(
                            _isEncrypting ? 'Encriptar' : 'Desencriptar',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Texto de salida
              Card(
                elevation: 8,
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.output, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Resultado',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _outputController,
                        maxLines: 5,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'El resultado aparecerá aquí...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.green, width: 1),
                          ),
                          filled: true,
                          fillColor: Colors.green.shade50,
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(_outputController.text),
                          icon: const Icon(Icons.copy),
                          label: const Text('Copiar Resultado'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botón para intercambiar
              Card(
                elevation: 8,
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
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _swapTexts,
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Intercambiar Modo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}