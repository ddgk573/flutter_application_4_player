import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/data/database.dart';
import 'package:flutter_application_4_player/features/playlists/add_song_dialog.dart';
import 'package:flutter_application_4_player/features/playlists/playlist_detail_screen.dart';

class PlayListScreen extends StatelessWidget {
  const PlayListScreen({super.key});

  void _open(BuildContext context, int? id, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaylistDetailScreen(playlistId: id, title: title),
      ),
    );
  }

  Future<void> _createPlaylist(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новый плейлист'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Название'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) await db.createPlaylist(name);
  }

  Future<void> _confirmDelete(BuildContext context, int id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Удалить «$name»?'),
        content: const Text('Песни останутся в приложении.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok == true) await db.deletePlaylist(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<QueryRow>>(
        stream: db.watchPlaylists(),
        builder: (context, snap) {
          final rows = snap.data ?? [];
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.library_music),
                title: const Text('Все песни'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, null, 'Все песни'),
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Новый плейлист'),
                onTap: () => _createPlaylist(context),
              ),
              const Divider(),
              for (final r in rows)
                ListTile(
                  leading: const Icon(Icons.queue_music),
                  title: Text(r.read<String>('name')),
                  subtitle: Text('Песен: ${r.read<int>('songs_count')}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _open(context, r.read<int>('id'), r.read<String>('name')),
                  onLongPress: () => _confirmDelete(
                    context,
                    r.read<int>('id'),
                    r.read<String>('name'),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Добавить песню',
        onPressed: () =>
            showDialog(context: context, builder: (_) => const AddSongDialog()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
