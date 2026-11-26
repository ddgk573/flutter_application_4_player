import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/core/app_state.dart';
import 'package:flutter_application_4_player/core/constants/themes.dart';
import 'package:flutter_application_4_player/screens/settings_screen.dart';
import 'package:flutter_application_4_player/screens/player_screen.dart';
import 'package:flutter_application_4_player/screens/play_list_screen.dart';

void main() {
  loadSwipeSettings();
  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, _) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _screen = const [
    PlayListScreen(),
    PlayerScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentTab,
      builder: (context, index, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Wave Player'),
          ),
          body: _screen[index],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: index,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            onTap: (i) => currentTab.value = i,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                label: 'Playlists',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_fill),
                label: 'Play',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
