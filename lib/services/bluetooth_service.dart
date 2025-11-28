import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  BluetoothConnection? _connection;

  bool get isConnected => _connection != null && _connection!.isConnected;

  Future<void> connect(String address) async {
    if (isConnected) return;
    _connection = await BluetoothConnection.toAddress(address);
    _connection!.input?.listen((event) {
      // log de lo que responde Arduino (opcional)
      print('Arduino -> ${String.fromCharCodes(event)}');
    }, onDone: () {
      _connection = null;
      print('Conexión BT cerrada por remoto');
    });
  }

  void send(String payload) {
    if (_connection == null || !_connection!.isConnected) {
      print('BT no conectado: intento enviar: $payload');
      return;
    }
    final bytes = Uint8List.fromList(payload.codeUnits);
    _connection!.output.add(bytes);
    _connection!.output.allSent;
    print('Enviado vía BT: $payload');
  }

  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
  }
}
