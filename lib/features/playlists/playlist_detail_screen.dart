import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/core/app_state.dart';
import 'package:flutter_application_4_player/data/database.dart';
import 'package:flutter_application_4_player/features/player/player.dart';
import 'package:flutter_application_4_player/widgets/song_cover.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final int? playlistId; // null = Все песни
  final String title;
  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.title,
  });

  Stream<List<SongView>> get _stream => playlistId == null
      ? db.watchAllSongs()
      : db.watchPlaylistSongs(playlistId!);

  Future<void> _play(
    BuildContext context,
    List<SongView> songs,
    int start,
  ) async {
    await PlayerController.instance.playQueue(songs, start);
    currentTab.value = 0;
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _addSongs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StreamBuilder<List<SongView>>(
        stream: db.watchAllSongs(),
        builder: (_, snap) {
          final all = snap.data ?? [];
          return ListView(
            children: [
              const ListTile(title: Text('Добавить в плейлист')),
              for (final s in all)
                ListTile(
                  leading: SongCover(path: s.coverPath),
                  title: Text(s.songName),
                  subtitle: Text(s.authorName),
                  trailing: const Icon(Icons.add),
                  onTap: () async {
                    await db.addSongToPlaylist(playlistId!, s.id);
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('«${s.songName}» добавлена')),
                      );
                    }
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (playlistId != null)
            IconButton(
              tooltip: 'Добавить песни',
              icon: const Icon(Icons.playlist_add),
              onPressed: () => _addSongs(context),
            ),
        ],
      ),
      body: StreamBuilder<List<SongView>>(
        stream: _stream,
        builder: (context, snap) {
          final songs = snap.data ?? [];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: songs.isEmpty
                        ? null
                        : () => _play(context, songs, 0),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                  ),
                ),
              ),
              Expanded(
                child: songs.isEmpty
                    ? const Center(child: Text('Здесь пока нет песен'))
                    : ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (_, i) => ListTile(
                          leading: SongCover(path: songs[i].coverPath),
                          title: Text(songs[i].songName),
                          subtitle: Text(songs[i].authorName),
                          onTap: () => _play(context, songs, i),
                          trailing: playlistId == null
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  tooltip: 'Убрать из плейлиста',
                                  onPressed: () => db.removeSongFromPlaylist(
                                    playlistId!,
                                    songs[i].id,
                                  ),
                                ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
