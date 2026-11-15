import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/core/constants/constants.dart';

class PlayAudio {
  static final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> play() async {
    try {
      await audioPlayer.play(DeviceFileSource(test_audio_path));
    } catch (e) {
      debugPrint('Ошибка воспроизведения: $e');
    }
  }
}
