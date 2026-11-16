import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/data/database.dart';

class PlayerController extends ChangeNotifier {
  PlayerController._() {
    _player.onPlayerComplete.listen((_) => next());
    _player.onPlayerStateChanged.listen((s) {
      isPlaying = s == PlayerState.playing;
      notifyListeners();
    });
  }
  static final PlayerController instance = PlayerController._();

  final AudioPlayer _player = AudioPlayer();
  List<SongView> queue = [];
  int index = -1;
  bool isPlaying = false;

  SongView? get current =>
      (index >= 0 && index < queue.length) ? queue[index] : null;

  Future<void> playQueue(List<SongView> songs, int start) async {
    queue = songs;
    await _playAt(start);
  }

  Future<void> _playAt(int i) async {
    if (i < 0 || i >= queue.length) return;
    index = i;
    notifyListeners();
    final path = queue[i].audioPath;
    if (path == null) {
      debugPrint('У песни нет аудиофайла');
      return;
    }
    try {
      await _player.play(DeviceFileSource(path));
      db.incrementListens(queue[i].id);
    } catch (e) {
      debugPrint('Ошибка воспроизведения: $e');
    }
  }

  Future<void> toggle() async {
    if (current == null) {
      final all = await db.watchAllSongs().first;
      if (all.isNotEmpty) await playQueue(all, 0);
    } else if (isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> next() async {
    if (queue.isEmpty) return;
    await _playAt(index + 1 < queue.length ? index + 1 : 0);
  }

  Future<void> prev() async {
    if (queue.isEmpty) return;
    await _playAt(index - 1 >= 0 ? index - 1 : queue.length - 1);
  }
}
