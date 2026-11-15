import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/core/constants/themes.dart';
import 'package:flutter_application_4_player/screens/settings_screen.dart';
import 'package:flutter_application_4_player/screens/player_screen.dart';
import 'package:flutter_application_4_player/screens/search_screen.dart';
import 'package:flutter_application_4_player/screens/play_list_screen.dart';
import 'package:flutter_application_4_player/screens/account_screen.dart';

void main() {
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
  int _currentScreen = 2;

  final List<Widget> _screen = [
    PlayListScreen(),
    SearchScreen(),
    PlayerScreen(),
    SettingsScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Wave Player'),
      ),
      body: _screen[_currentScreen],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentScreen,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        onTap: (index) {
          setState(() {
            _currentScreen = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
