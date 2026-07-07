class Acordes {
  static const List<String> notas = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  static const Map<String, String> bemolParaSustenido = {
    'Db': 'C#',
    'Eb': 'D#',
    'Gb': 'F#',
    'Ab': 'G#',
    'Bb': 'A#',
  };

  static String normalizar(String nota) {
    return bemolParaSustenido[nota] ?? nota;
  }

  static String transporNota(String nota, int semitons) {
    final normalizada = normalizar(nota);
    final index = notas.indexOf(normalizada);

    if (index == -1) return nota;

    final novoIndex = (index + semitons) % notas.length;

    if (novoIndex < 0) {
      return notas[novoIndex + notas.length];
    }

    return notas[novoIndex];
  }
}