import '../utils/acordes.dart';

class TranspositorService {
  static final RegExp acordeRegex = RegExp(
    r'(?<![A-Za-z])([A-G](?:#|b)?)([a-zA-Z0-9#bº°+\-]*)?(?:\/([A-G](?:#|b)?))?',
  );

  static String transporCifra(String cifra, int semitons) {
    return cifra.split('\n').map((linha) {
      return linha.replaceAllMapped(acordeRegex, (match) {
        final nota = match.group(1);
        final complemento = match.group(2) ?? '';
        final baixo = match.group(3);

        if (nota == null) return match.group(0) ?? '';

        final novaNota = Acordes.transporNota(nota, semitons);
        final novoBaixo =
            baixo == null ? null : Acordes.transporNota(baixo, semitons);

        if (novoBaixo != null) {
          return '$novaNota$complemento/$novoBaixo';
        }

        return '$novaNota$complemento';
      });
    }).join('\n');
  }

  static String transporTom(String tom, int semitons) {
    if (tom.trim().isEmpty) return tom;

    final match = RegExp(r'^([A-G](?:#|b)?)(.*)$').firstMatch(tom.trim());

    if (match == null) return tom;

    final nota = match.group(1) ?? tom;
    final complemento = match.group(2) ?? '';

    return '${Acordes.transporNota(nota, semitons)}$complemento';
  }
}