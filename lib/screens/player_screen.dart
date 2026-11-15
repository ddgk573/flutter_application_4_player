import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/features/player/player.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: const Text("Play", style: TextStyle(fontSize: 22)),
            onPressed: () async {
              await PlayAudio().play();
            },
          ),
        ],
      ),
    );
  }
}
