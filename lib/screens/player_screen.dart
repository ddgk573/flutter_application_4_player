import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/data/database.dart';
import 'package:flutter_application_4_player/features/player/player.dart';
import 'package:flutter_application_4_player/widgets/song_cover.dart';
import 'package:flutter_application_4_player/widgets/seek_bar.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = PlayerController.instance;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final song = c.current;
        return Column(
          children: [
            const SizedBox(height: 16),
            SongCover(path: song?.coverPath, size: 240),
            const SizedBox(height: 12),
            Text(
              song?.songName ?? 'Ничего не играет',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (song != null) Text(song.authorName),
            const SizedBox(height: 8),
            const SeekBar(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: c.queue.isEmpty ? null : c.prev,
                ),
                IconButton.filled(
                  iconSize: 44,
                  icon: Icon(c.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: c.toggle,
                ),
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.skip_next),
                  onPressed: c.queue.isEmpty ? null : c.next,
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: c.queue.isNotEmpty
                  ? _songList(c, c.queue, highlight: true)
                  : StreamBuilder<List<SongView>>(
                      stream: db.watchAllSongs(),
                      builder: (_, snap) {
                        final all = snap.data ?? [];
                        if (all.isEmpty) {
                          return const Center(child: Text('Песен пока нет'));
                        }
                        return _songList(c, all, highlight: false);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _songList(
    PlayerController c,
    List<SongView> songs, {
    required bool highlight,
  }) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (_, i) => ListTile(
        selected: highlight && i == c.index,
        leading: SongCover(path: songs[i].coverPath),
        title: Text(songs[i].songName),
        subtitle: Text(songs[i].authorName),
        onTap: () => c.playQueue(songs, i),
      ),
    );
  }
}
