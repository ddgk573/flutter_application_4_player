import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/core/app_state.dart';
import 'package:flutter_application_4_player/data/database.dart';
import 'package:flutter_application_4_player/widgets/song_cover.dart';

class SwipeSongTile extends StatelessWidget {
  final SongView song;
  final int? currentPlaylistId;
  final VoidCallback onTap;
  final Widget? trailing;

  const SwipeSongTile({
    super.key,
    required this.song,
    required this.currentPlaylistId,
    required this.onTap,
    this.trailing,
  });

  Future<String?> _askPlaylistName(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
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
  }

  Future<void> _performAction(
    BuildContext context,
    SwipeSongAction action,
  ) async {
    if (action == SwipeSongAction.none) return;

    String? resultMessage;
    int? targetId;
    if (action == SwipeSongAction.addToCurrentPlaylist) {
      targetId = currentPlaylistId ?? lastPlaylistId.value;
      if (targetId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Сначала откройте плейлист')),
          );
        }
        return;
      }
      if (!await db.playlistExists(targetId)) {
        if (targetId == lastPlaylistId.value) await setLastPlaylist(null);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Выбранный плейлист не найден')),
          );
        }
        return;
      }
      final added = await db.addSongToPlaylist(targetId, song.id);
      resultMessage = added
          ? 'Добавлено в текущий плейлист'
          : 'Песня уже есть в плейлисте';
    } else if (action == SwipeSongAction.removeFromPlaylist) {
      if (currentPlaylistId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Песня не находится в плейлисте')),
          );
        }
        return;
      }
      final deletedRows = await db.removeSongFromPlaylist(
        currentPlaylistId!,
        song.id,
      );
      resultMessage = deletedRows == 0
          ? 'Песня не находится в плейлисте'
          : 'Удалено из плейлиста';
    } else if (action == SwipeSongAction.addToLastPlaylist) {
      targetId = lastPlaylistId.value;
      if (targetId != null && !await db.playlistExists(targetId)) {
        targetId = null;
        await setLastPlaylist(null);
      }
      if (targetId == null) {
        if (!context.mounted) return;
        final name = await _askPlaylistName(context);
        if (name == null || name.isEmpty) return;
        targetId = await db.createPlaylist(name);
        await setLastPlaylist(targetId);
      }
      final added = await db.addSongToPlaylist(targetId, song.id);
      resultMessage = added
          ? 'Добавлено в последний плейлист'
          : 'Песня уже есть в плейлисте';
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resultMessage ?? song.songName)));
    }
  }

  @override
  Widget build(BuildContext context) {
    var dragDistance = 0.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => dragDistance = 0,
      onHorizontalDragUpdate: (details) => dragDistance += details.delta.dx,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        final direction = dragDistance.abs() >= 48
            ? dragDistance.sign
            : velocity.abs() >= 300
            ? velocity.sign
            : 0;
        if (direction > 0) {
          _performAction(context, rightSwipeAction.value);
        } else if (direction < 0) {
          _performAction(context, leftSwipeAction.value);
        }
      },
      child: ListTile(
        leading: SongCover(path: song.coverPath),
        title: Text(song.songName),
        subtitle: Text(song.authorName),
        onTap: onTap,
        trailing: trailing,
      ),
    );
  }
}
