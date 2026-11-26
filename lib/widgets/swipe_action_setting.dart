import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/core/app_state.dart';

class SwipeActionSetting extends StatelessWidget {
  final String title;
  final ValueNotifier<SwipeSongAction> notifier;
  final SwipeDirection direction;

  const SwipeActionSetting({
    super.key,
    required this.title,
    required this.notifier,
    required this.direction,
  });

  String _label(SwipeSongAction action) {
    return switch (action) {
      SwipeSongAction.addToCurrentPlaylist => 'Добавить в текущий плейлист',
      SwipeSongAction.removeFromPlaylist => 'Удалить из плейлиста',
      SwipeSongAction.addToLastPlaylist => 'Добавить в последний плейлист',
      SwipeSongAction.none => 'Ничего не делать',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SwipeSongAction>(
      valueListenable: notifier,
      builder: (_, action, _) {
        return ListTile(
          title: Text(title),
          trailing: DropdownButton<SwipeSongAction>(
            value: action,
            underline: const SizedBox.shrink(),
            isDense: true,
            onChanged: (value) {
              if (value != null) {
                setSwipeAction(direction, value);
              }
            },
            items: SwipeSongAction.values
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(_label(option)),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
