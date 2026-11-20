import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SongMetadata {
  final String? title;
  final String? artist;
  final Uint8List? coverBytes;
  final String? coverMimeType;

  const SongMetadata({
    this.title,
    this.artist,
    this.coverBytes,
    this.coverMimeType,
  });
}

Future<SongMetadata> readSongMetadata(String filePath) async {
  final metadata = await Isolate.run<Map<String, Object?>>(() {
    final audioMetadata = readMetadata(File(filePath), getImage: true);
    final cover = audioMetadata.pictures.isEmpty
        ? null
        : audioMetadata.pictures.first;

    return {
      'title': audioMetadata.title,
      'artist': audioMetadata.artist,
      'coverBytes': cover?.bytes,
      'coverMimeType': cover?.mimetype,
    };
  });

  return SongMetadata(
    title: metadata['title'] as String?,
    artist: metadata['artist'] as String?,
    coverBytes: metadata['coverBytes'] as Uint8List?,
    coverMimeType: metadata['coverMimeType'] as String?,
  );
}

Future<String> saveEmbeddedCover(Uint8List bytes, String? mimeType) async {
  final extension = switch (mimeType?.toLowerCase()) {
    'image/png' => 'png',
    'image/gif' => 'gif',
    'image/webp' => 'webp',
    'image/bmp' => 'bmp',
    _ => 'jpg',
  };
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final coversDirectory = Directory(p.join(documentsDirectory.path, 'covers'));
  await coversDirectory.create(recursive: true);

  final coverFile = File(
    p.join(
      coversDirectory.path,
      'embedded_${DateTime.now().microsecondsSinceEpoch}.$extension',
    ),
  );
  await coverFile.writeAsBytes(bytes, flush: true);
  return coverFile.path;
}
