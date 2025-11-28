import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:llm_toolkit/llm_toolkit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LLMToolkit.instance.initialize(
    defaultConfig: InferenceConfig.mobile(),
  );
  runApp(const VoiceCarApp());
}

class VoiceCarApp extends StatelessWidget {
  const VoiceCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carro por Voz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}