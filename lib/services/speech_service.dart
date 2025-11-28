import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  Future<bool> init() async {
    return await _speech.initialize(
      onError: (e) => print('Speech error: $e'),
      onStatus: (s) => print('Speech status: $s'),
    );
  }

  Future<String> listen({int seconds = 4, String locale = 'es_MX'}) async {
    final completer = Completer<String>();
    String recognized = "";

    _speech.listen(
      onResult: (res) {
        recognized = res.recognizedWords;
        if (res.finalResult && !completer.isCompleted) {
          completer.complete(recognized);
        }
      },
      listenFor: Duration(seconds: seconds),
      localeId: locale,
      cancelOnError: true,
    );

    // Timeout fallback
    Future.delayed(Duration(seconds: seconds + 1), () {
      if (!completer.isCompleted) completer.complete(recognized);
    });

    final text = await completer.future;
    await stop();
    return text;
  }

  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (e) {
      // ignore
    }
  }
}
