import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'song_view.dart';

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

export 'song_view.dart';

part 'database.g.dart';

class Authors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100).unique()();
}

class Songs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get songName => text().withLength(min: 1, max: 100)();
  IntColumn get authorId =>
      integer().references(Authors, #id, onDelete: KeyAction.restrict)();
  TextColumn get audioPath => text().nullable()();
  TextColumn get coverPath => text().nullable()();
  IntColumn get listensAll => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {songName, authorId},
  ];
}

class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get coverPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class PlaylistSongs extends Table {
  IntColumn get playlistId =>
      integer().references(Playlists, #id, onDelete: KeyAction.cascade)();
  IntColumn get songId =>
      integer().references(Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, songId};
}

@DriftDatabase(tables: [Authors, Songs, Playlists, PlaylistSongs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'app_db'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Stream<List<SongView>> watchAllSongs() {
    return customSelect(
      '''
    SELECT s.id, s.song_name, s.audio_path, s.cover_path, s.listens_all,
           a.name AS author_name
    FROM songs s
    JOIN authors a ON a.id = s.author_id
    ORDER BY s.song_name
    ''',
      readsFrom: {songs, authors},
    ).watch().map((rows) => rows.map(SongView.fromRow).toList());
  }

  Future<int> getOrCreateAuthor(String name) async {
    await customInsert(
      'INSERT OR IGNORE INTO authors (name) VALUES (?)',
      variables: [Variable.withString(name)],
      updates: {authors},
    );
    final row = await customSelect(
      'SELECT id FROM authors WHERE name = ?',
      variables: [Variable.withString(name)],
    ).getSingle();
    return row.read<int>('id');
  }

  Future<int> createPlaylist(String name) => customInsert(
    'INSERT INTO playlists (name) VALUES (?)',
    variables: [Variable.withString(name)],
    updates: {playlists},
  );

  Stream<List<QueryRow>> watchPlaylists() => customSelect(
    '''
      SELECT p.id, p.name, p.cover_path, COUNT(ps.song_id) AS songs_count
      FROM playlists p
      LEFT JOIN playlist_songs ps ON ps.playlist_id = p.id
      GROUP BY p.id
      ORDER BY p.created_at DESC
      ''',
    readsFrom: {playlists, playlistSongs},
  ).watch();

  Stream<List<SongView>> watchPlaylistSongs(int playlistId) {
    return customSelect(
      '''
    SELECT s.id, s.song_name, s.audio_path, s.cover_path, s.listens_all,
           a.name AS author_name
    FROM playlist_songs ps
    JOIN songs s ON s.id = ps.song_id
    JOIN authors a ON a.id = s.author_id
    WHERE ps.playlist_id = ?
    ORDER BY ps.position
    ''',
      variables: [Variable.withInt(playlistId)],
      readsFrom: {playlistSongs, songs, authors},
    ).watch().map((rows) => rows.map(SongView.fromRow).toList());
  }

  Future<int> addSongToPlaylist(int playlistId, int songId) => customInsert(
    '''
      INSERT OR IGNORE INTO playlist_songs (playlist_id, song_id, position)
      VALUES (?, ?, (SELECT COALESCE(MAX(position), -1) + 1
                     FROM playlist_songs WHERE playlist_id = ?))
      ''',
    variables: [
      Variable.withInt(playlistId),
      Variable.withInt(songId),
      Variable.withInt(playlistId),
    ],
    updates: {playlistSongs},
  );

  Future<int> removeSongFromPlaylist(int playlistId, int songId) =>
      customUpdate(
        'DELETE FROM playlist_songs WHERE playlist_id = ? AND song_id = ?',
        variables: [Variable.withInt(playlistId), Variable.withInt(songId)],
        updates: {playlistSongs},
        updateKind: UpdateKind.delete,
      );

  Future<int> deletePlaylist(int id) => customUpdate(
    'DELETE FROM playlists WHERE id = ?', // связи удалятся каскадом
    variables: [Variable.withInt(id)],
    updates: {playlists, playlistSongs},
    updateKind: UpdateKind.delete,
  );

  Future<int> incrementListens(int songId) => customUpdate(
    'UPDATE songs SET listens_all = listens_all + 1 WHERE id = ?',
    variables: [Variable.withInt(songId)],
    updates: {songs},
    updateKind: UpdateKind.update,
  );

  Future<void> reorderPlaylist(int playlistId, List<int> orderedSongIds) {
    return transaction(() async {
      for (var i = 0; i < orderedSongIds.length; i++) {
        await customUpdate(
          'UPDATE playlist_songs SET position = ? '
          'WHERE playlist_id = ? AND song_id = ?',
          variables: [
            Variable.withInt(i),
            Variable.withInt(playlistId),
            Variable.withInt(orderedSongIds[i]),
          ],
          updates: {playlistSongs},
          updateKind: UpdateKind.update,
        );
      }
    });
  }

  Future<int> addSong({
    required String name,
    required String author,
    required String audioPath,
    String? coverPath,
    int? playlistId,
  }) {
    return transaction(() async {
      final authorId = await getOrCreateAuthor(author);
      final songId = await customInsert(
        'INSERT INTO songs (song_name, author_id, audio_path, cover_path) '
        'VALUES (?, ?, ?, ?)',
        variables: [
          Variable.withString(name),
          Variable.withInt(authorId),
          Variable.withString(audioPath),
          Variable(coverPath),
        ],
        updates: {songs},
      );
      if (playlistId != null) await addSongToPlaylist(playlistId, songId);
      return songId;
    });
  }

  Future<String?> pickAndSave(FileType type, String subfolder) async {
    final file = await FilePicker.pickFile(type: type);
    final sourcePath = file?.path;
    if (sourcePath == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, subfolder));
    await folder.create(recursive: true);

    final newPath = p.join(
      folder.path,
      '${DateTime.now().millisecondsSinceEpoch}_${p.basename(sourcePath)}',
    );
    await File(sourcePath).copy(newPath);
    return newPath;
  }
}

final db = AppDatabase();
