class CommandParser {
  /// Devuelve secuencia de comandos (F,B,L,R,S)
  static List<String> toCarCommands(String text) {
    final t = text.toLowerCase();
    final out = <String>[];

    // Detección simple. Ajusta sinónimos según necesites.
    if (t.contains('deten') || t.contains('alto') || t.contains('parar') || t.contains('stop')) out.add('S');
    if (t.contains('adelante') || t.contains('avanza') || t.contains('avanzar')) out.add('F');
    if (t.contains('retro') || t.contains('reversa') || t.contains('retrocede')) out.add('B');
    if (t.contains('izquierda')) out.add('L');
    if (t.contains('derecha')) out.add('R');

    if (out.isEmpty) out.add('S'); // fallback
    return out;
  }

  static String toPayload(List<String> commands) {
    // Separar con newline para Arduino
    return commands.map((c) => '$c\n').join();
  }
}
