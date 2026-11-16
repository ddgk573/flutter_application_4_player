import 'dart:io';

import 'package:drift/drift.dart' show QueryRow;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/data/database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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

class AddSongDialog extends StatefulWidget {
  final int? playlistId;
  const AddSongDialog({super.key, this.playlistId});

  @override
  State<AddSongDialog> createState() => _AddSongDialogState();
}

class _AddSongDialogState extends State<AddSongDialog> {
  final _name = TextEditingController();
  final _author = TextEditingController();
  String? _audioPath;
  String? _coverPath;
  int? _playlistId;
  String? _error;
  bool _saving = false;
  late final Future<List<QueryRow>> _playlists = db.watchPlaylists().first;

  @override
  void initState() {
    super.initState();
    _playlistId = widget.playlistId;
  }

  @override
  void dispose() {
    _name.dispose();
    _author.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    final path = await pickAndSave(FileType.audio, 'audio');
    if (path != null) setState(() => _audioPath = path);
  }

  Future<void> _pickCover() async {
    final path = await pickAndSave(FileType.image, 'covers');
    if (path != null) setState(() => _coverPath = path);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final author = _author.text.trim();
    if (name.isEmpty || author.isEmpty) {
      setState(() => _error = 'Введите название и автора');
      return;
    }
    if (_audioPath == null) {
      setState(() => _error = 'Выберите mp3-файл');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await db.addSong(
        name: name,
        author: author,
        audioPath: _audioPath!,
        coverPath: _coverPath,
        playlistId: _playlistId,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Ошибка сохранения песни: $e');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Не удалось сохранить: такая песня уже есть?';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новая песня'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: _author,
              decoration: const InputDecoration(labelText: 'Автор'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickAudio,
              icon: const Icon(Icons.audiotrack),
              label: Text(
                _audioPath == null ? 'Выбрать mp3' : p.basename(_audioPath!),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            OutlinedButton.icon(
              onPressed: _pickCover,
              icon: const Icon(Icons.image),
              label: Text(
                _coverPath == null
                    ? 'Выбрать обложку'
                    : p.basename(_coverPath!),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<QueryRow>>(
              future: _playlists,
              builder: (_, snap) {
                final rows = snap.data ?? [];
                return DropdownButtonFormField<int?>(
                  initialValue: _playlistId,
                  decoration: const InputDecoration(
                    labelText: 'Плейлист (необязательно)',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Без плейлиста'),
                    ),
                    for (final r in rows)
                      DropdownMenuItem(
                        value: r.read<int>('id'),
                        child: Text(r.read<String>('name')),
                      ),
                  ],
                  onChanged: (v) => setState(() => _playlistId = v),
                );
              },
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
