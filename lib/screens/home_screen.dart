import 'package:flutter/material.dart';
import '../services/speech_service.dart';
import '../services/bluetooth_service.dart';
import '../services/llm_service.dart';
import '../logic/command_parser.dart';
import 'package:llm_toolkit/llm_toolkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final speech = SpeechService();
  final bt = BluetoothService();
  final llm = LLMService();

  String recognized = '';
  String llmResponse = '';
  String lastSent = '';
  bool modelLoaded = false;
  bool btConnected = false;

  final TextEditingController _btCtrl = TextEditingController(text: '00:21:13:01:23:45');

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    await speech.init();

    // Cargar modelo (copiar de assets a storage y luego load)
    try {
      await llm.loadModelFromAssets('assets/models/llama-1b-instruct-q4.gguf');
      setState(() => modelLoaded = true);
    } catch (e) {
      print('Error cargando LLM: $e');
    }
  }

  Future<void> connectBT() async {
    try {
      await bt.connect(_btCtrl.text.trim());
      setState(() => btConnected = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('BT error: $e')));
    }
  }

  Future<void> processAndSend() async {
    setState(() {
      recognized = '';
      llmResponse = '';
    });

    final text = await speech.listen(seconds: 4, locale: 'es_MX');
    setState(() => recognized = text);

    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se reconoció nada')));
      return;
    }

    final prompt = '''
Eres un asistente que convierte instrucciones de movimiento en acciones breves para un carrito. 
Usuario: "$text"
Responde con una breve descripción de la acción (ej: "adelante", "gira izquierda luego adelante", "detener").
''';

    try {
      final resp = await llm.generate(prompt, params: GenerationParams.custom(maxTokens: 128, temperature: 0.1));
      setState(() => llmResponse = resp);
    } catch (e) {
      setState(() => llmResponse = 'LLM error: $e');
      return;
    }

    final commands = CommandParser.toCarCommands(llmResponse);
    final payload = CommandParser.toPayload(commands);
    bt.send(payload);
    setState(() => lastSent = payload);
  }

  @override
  void dispose() {
    bt.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control por voz + LLM (offline)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _btCtrl, decoration: const InputDecoration(labelText: 'Dirección HC-05')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: connectBT, child: Text(btConnected ? 'Conectado' : 'Conectar BT')),
            const Divider(),

            ListTile(title: const Text('Modelo LLM'), subtitle: Text(modelLoaded ? 'Cargado' : 'No cargado')),

            ElevatedButton.icon(
              onPressed: modelLoaded && btConnected ? processAndSend : null,
              icon: const Icon(Icons.mic),
              label: const Text('Hablar y enviar'),
            ),

            const SizedBox(height: 12),
            Text('🗣️ Reconocido:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(recognized),
            const SizedBox(height: 8),
            Text('🤖 LLM respondió:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(llmResponse),
            const SizedBox(height: 8),
            Text('📤 Último enviado:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(lastSent),
          ],
        ),
      ),
    );
  }
}
