import 'dart:io';

import 'manifest_cfl.dart';
import 'musica.dart';

class CflPackage {
  final ManifestCfl manifest;

  final Musica musica;

  final File? playback;

  final File? lrc;

  final File? cover;

  const CflPackage({
    required this.manifest,
    required this.musica,
    this.playback,
    this.lrc,
    this.cover,
  });

  bool get possuiPlayback => playback != null;

  bool get possuiLrc => lrc != null;

  bool get possuiCover => cover != null;
}