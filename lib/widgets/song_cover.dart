import 'dart:io';

import 'package:flutter/material.dart';

class SongCover extends StatelessWidget {
  final String? path;
  final double size;
  const SongCover({super.key, this.path, this.size = 48});

  Widget _placeholder() => Container(
    width: size,
    height: size,
    color: Colors.grey.shade300,
    child: Icon(Icons.music_note, size: size / 2),
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: path == null
          ? _placeholder()
          : Image.file(
              File(path!),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(),
            ),
    );
  }
}
