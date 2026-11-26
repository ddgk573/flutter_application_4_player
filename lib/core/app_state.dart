import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int kPlayerTab = 2;

final ValueNotifier<int> currentTab = ValueNotifier<int>(kPlayerTab);

enum SwipeSongAction {
  addToCurrentPlaylist,
  removeFromPlaylist,
  addToLastPlaylist,
  none,
}

const _leftSwipeKey = 'swipe_left_action';
const _rightSwipeKey = 'swipe_right_action';
const _lastPlaylistKey = 'last_playlist_id';

final ValueNotifier<SwipeSongAction> leftSwipeAction = ValueNotifier(
  SwipeSongAction.none,
);
final ValueNotifier<SwipeSongAction> rightSwipeAction = ValueNotifier(
  SwipeSongAction.none,
);
final ValueNotifier<int?> lastPlaylistId = ValueNotifier<int?>(null);

SwipeSongAction _decodeSwipeAction(String? value) {
  return SwipeSongAction.values.firstWhere(
    (action) => action.name == value,
    orElse: () => SwipeSongAction.none,
  );
}

Future<void> loadSwipeSettings() async {
  final prefs = await SharedPreferences.getInstance();
  leftSwipeAction.value = _decodeSwipeAction(prefs.getString(_leftSwipeKey));
  rightSwipeAction.value = _decodeSwipeAction(prefs.getString(_rightSwipeKey));
  lastPlaylistId.value = prefs.getInt(_lastPlaylistKey);
}

Future<void> setSwipeAction(
  SwipeDirection direction,
  SwipeSongAction action,
) async {
  final prefs = await SharedPreferences.getInstance();
  if (direction == SwipeDirection.left) {
    leftSwipeAction.value = action;
    await prefs.setString(_leftSwipeKey, action.name);
  } else {
    rightSwipeAction.value = action;
    await prefs.setString(_rightSwipeKey, action.name);
  }
}

enum SwipeDirection { left, right }

Future<void> setLastPlaylist(int? id) async {
  lastPlaylistId.value = id;
  final prefs = await SharedPreferences.getInstance();
  if (id == null) {
    await prefs.remove(_lastPlaylistKey);
  } else {
    await prefs.setInt(_lastPlaylistKey, id);
  }
}
