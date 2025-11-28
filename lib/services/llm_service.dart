import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:llm_toolkit/llm_toolkit.dart';

class LLMService {
  bool _loaded = false;
  String? _modelPath;

  bool get isLoaded => _loaded;

  /// Copia el modelo desde assets al storage de la app y lo carga con llm_toolkit.
  Future<void> loadModelFromAssets(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();

    final docs = await getApplicationDocumentsDirectory();
    final filename = assetPath.split('/').last;
    final filePath = '${docs.path}/$filename';
    final file = File(filePath);

    if (!await file.exists()) {
      await file.writeAsBytes(bytes);
    }

    // Guarda ruta
    _modelPath = filePath;

    // Carga el modelo usando la API del toolkit
    await LLMToolkit.instance.loadModel(
      _modelPath!,
      config: InferenceConfig.mobile(),
    );

    _loaded = true;
  }

  /// Genera texto a partir de prompt; recolecta el stream en un String.
  Future<String> generate(String prompt,
      {GenerationParams? params}) async {
    if (!_loaded) throw Exception('Modelo no cargado');

    final buffer = StringBuffer();
    final genParams = params ?? GenerationParams.balanced();

    await for (final chunk in LLMToolkit.instance.generateText(
      prompt,
      params: genParams,
    )) {
      buffer.write(chunk);
    }

    return buffer.toString();
  }
}
