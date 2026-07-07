import 'musica.dart';
import 'lrc_linha.dart';

class ClvImportado {
  final Musica musica;
  final List<LrcLinha> sincronizacao;

  ClvImportado({
    required this.musica,
    required this.sincronizacao,
  });
}