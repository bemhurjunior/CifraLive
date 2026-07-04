class Repertorio {
  String nome;
  List<String> musicas;

  Repertorio({
    required this.nome,
    required this.musicas,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'musicas': musicas,
    };
  }

  factory Repertorio.fromMap(Map<String, dynamic> map) {
    return Repertorio(
      nome: map['nome'] ?? '',
      musicas: List<String>.from(map['musicas'] ?? []),
    );
  }
}