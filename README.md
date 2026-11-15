# Wave Player

Flutter-приложение с нижней навигацией между экранами плеера, поиска,
плейлистов, настроек и профиля.

## Архитектура

В проекте используется упрощённая архитектура с разделением на слои:

- `lib/main.dart` — точка входа приложения и корневой виджет `MyApp`.
- `lib/screens` — UI-экраны навигации и экранов приложения.
- `lib/features` — доменная/функциональная логика, например воспроизведение аудио.
- `lib/core/constants` — общие темы и константы.
- `lib/data` — подготовленный слой данных/БД для дальнейшего расширения.

```mermaid
flowchart TD
    main["main.dart\nrunApp()"] --> app["MyApp"]
    app --> material["MaterialApp"]
    app --> themeState["themeNotifier\nValueNotifier<ThemeMode>"]
    material --> home["MyHomePage"]

    themeState --> material

    home --> scaffold["Scaffold"]
    scaffold --> nav["BottomNavigationBar"]
    nav -->|"выбирает индекс"| home
    scaffold --> body["_screen[currentIndex]"]
    screens["UI-слой\nlib/screens"] --> body

    body --> playlists["PlayListScreen"]
    body --> search["SearchScreen"]
    body --> player["PlayerScreen"]
    body --> settings["SettingsScreen"]
    body --> account["AccountScreen"]

    settings -->|"читает и меняет тему"| themeState

    player --> feature["features/player/player.dart\nPlayAudio"]
    feature --> audio["audioplayers"]
    feature --> audioPath["core/constants/constants.dart\ntest_audio_path"]

    material --> theme["core/constants/themes.dart\nAppTheme"]
    theme --> light["lightTheme"]
    theme --> dark["darkTheme"]

    data["data/databas.dart"] -.->|"планируется для хранения данных"| screens
```

## Getting Started
