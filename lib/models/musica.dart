class Musica {
  final String nome;
  final String artista;
  final String tom;
  final String cifra;
  bool favorita;

  final String playbackPath;
  final String lrcPath;
  final String clvPath;
  final int bpm;
  final double volume;

  Musica({
    required this.nome,
    required this.artista,
    required this.tom,
    required this.cifra,
    this.favorita = false,
    this.playbackPath = '',
    this.lrcPath = '',
    this.clvPath = '',
    this.bpm = 0,
    this.volume = 1.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'artista': artista,
      'tom': tom,
      'cifra': cifra,
      'favorita': favorita,
      'playbackPath': playbackPath,
      'lrcPath': lrcPath,
      'clvPath': clvPath,
      'bpm': bpm,
      'volume': volume,
    };
  }

  factory Musica.fromMap(Map<String, dynamic> map) {
    return Musica(
      nome: map['nome'] ?? '',
      artista: map['artista'] ?? '',
      tom: map['tom'] ?? '',
      cifra: map['cifra'] ?? '',
      favorita: map['favorita'] ?? false,
      playbackPath: map['playbackPath'] ?? '',
      lrcPath: map['lrcPath'] ?? '',
      clvPath: map['clvPath'] ?? '',
      bpm: map['bpm'] ?? 0,
      volume: (map['volume'] ?? 1.0).toDouble(),
    );
  }
}