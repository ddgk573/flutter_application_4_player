import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/main.dart';
import 'package:flutter_application_4_player/core/app_state.dart';
import 'package:flutter_application_4_player/widgets/swipe_action_setting.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Тёмная тема:', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (_, currentMode, _) {
                return Switch(
                  value: currentMode == ThemeMode.dark,
                  onChanged: (bool isDark) {
                    themeNotifier.value = isDark
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                );
              },
            ),
          ],
        ),
        const Divider(height: 32),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Действия свайпа по песне',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SwipeActionSetting(
          title: 'Влево',
          notifier: leftSwipeAction,
          direction: SwipeDirection.left,
        ),
        SwipeActionSetting(
          title: 'Вправо',
          notifier: rightSwipeAction,
          direction: SwipeDirection.right,
        ),
      ],
    );
  }
}
