class Musica {
  final String nome;
  final String artista;
  final String tom;
  final String cifra;
  bool favorita;

  Musica({
    required this.nome,
    required this.artista,
    required this.tom,
    required this.cifra,
    this.favorita = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'artista': artista,
      'tom': tom,
      'cifra': cifra,
      'favorita': favorita,
    };
  }

  factory Musica.fromMap(Map<String, dynamic> map) {
    return Musica(
      nome: map['nome'] ?? '',
      artista: map['artista'] ?? '',
      tom: map['tom'] ?? '',
      cifra: map['cifra'] ?? '',
      favorita: map['favorita'] ?? false,
    );
  }
}