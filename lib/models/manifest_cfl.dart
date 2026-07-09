import 'dart:convert';

class ManifestCfl {
  final String formato;
  final String versaoFormato;
  final String id;
  final String criadoPor;
  final DateTime dataCriacao;

  const ManifestCfl({
    required this.formato,
    required this.versaoFormato,
    required this.id,
    required this.criadoPor,
    required this.dataCriacao,
  });

  factory ManifestCfl.novo({
    required String id,
  }) {
    return ManifestCfl(
      formato: 'CFL',
      versaoFormato: '1.0',
      id: id,
      criadoPor: 'CifraLive',
      dataCriacao: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'formato': formato,
      'versaoFormato': versaoFormato,
      'id': id,
      'criadoPor': criadoPor,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory ManifestCfl.fromMap(Map<String, dynamic> map) {
    return ManifestCfl(
      formato: map['formato'] ?? 'CFL',
      versaoFormato: map['versaoFormato'] ?? '1.0',
      id: map['id'] ?? '',
      criadoPor: map['criadoPor'] ?? 'CifraLive',
      dataCriacao: DateTime.tryParse(
            map['dataCriacao'] ?? '',
          ) ??
          DateTime.now(),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory ManifestCfl.fromJson(String source) {
    return ManifestCfl.fromMap(
      jsonDecode(source),
    );
  }
}