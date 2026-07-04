class Musica {
  final String nome;
  final String artista;
  final String tom;
  final String cifra;

  Musica({
    required this.nome,
    required this.artista,
    required this.tom,
    required this.cifra,
  });

  Map<String, String> toMap() {
    return {
      'nome': nome,
      'artista': artista,
      'tom': tom,
      'cifra': cifra,
    };
  }

  factory Musica.fromMap(Map<String, String> map) {
    return Musica(
      nome: map['nome'] ?? '',
      artista: map['artista'] ?? '',
      tom: map['tom'] ?? '',
      cifra: map['cifra'] ?? '',
    );
  }
}