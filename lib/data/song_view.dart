import 'package:drift/drift.dart' show QueryRow;

class SongView {
  final int id;
  final String songName;
  final String authorName;
  final String? audioPath;
  final String? coverPath;
  final int listensAll;

  SongView({
    required this.id,
    required this.songName,
    required this.authorName,
    this.audioPath,
    this.coverPath,
    required this.listensAll,
  });

  factory SongView.fromRow(QueryRow r) => SongView(
    id: r.read<int>('id'),
    songName: r.read<String>('song_name'),
    authorName: r.read<String>('author_name'),
    audioPath: r.read<String?>('audio_path'),
    coverPath: r.read<String?>('cover_path'),
    listensAll: r.read<int>('listens_all'),
  );
}
