import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            textDirection: TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
            ],
          ),
        ],
      ),
    );
  }
}
