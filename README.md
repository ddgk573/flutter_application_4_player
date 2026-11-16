# Wave Player

Flutter-приложение с нижней навигацией между экранами плеера, поиска,
плейлистов, настроек и профиля.

## Архитектура

В проекте используется упрощённая архитектура с разделением на слои:

- `lib/main.dart` — точка входа, корневой виджет `MyApp` и нижняя навигация.
- `lib/screens` — основные экраны приложения.
- `lib/features` — сценарии плейлистов и управление воспроизведением.
- `lib/core` — состояние выбранной вкладки и тема приложения.
- `lib/data` — Drift-база данных, запросы и представление песни.
- `lib/widgets` — повторно используемые UI-компоненты.

```mermaid
flowchart TD
    main["main.dart · runApp()"] --> app["MyApp"]
    themeNotifier["themeNotifier\nValueNotifier<ThemeMode>"] --> app
    app --> material["MaterialApp"]
    appTheme["AppTheme\nlightTheme / darkTheme"] --> material
    material --> home["MyHomePage"]

    home --> tabState["currentTab\ncore/app_state.dart"]
    tabState --> nav["BottomNavigationBar"]
    nav -->|"меняет выбранную вкладку"| tabState
    home --> screenList["_screen[currentTab]"]
    screenList --> playlists["PlayListScreen"]
    screenList --> search["SearchScreen\nзаготовка"]
    screenList --> playerScreen["PlayerScreen"]
    screenList --> settings["SettingsScreen"]
    screenList --> account["AccountScreen\nзаготовка"]
    settings -->|"читает и меняет"| themeNotifier

    playlists -->|"открывает"| playlistDetail["PlaylistDetailScreen"]
    playlists -->|"создаёт песню"| addSong["AddSongDialog"]
    playlistDetail -->|"список песен и плейлистов"| db["db · AppDatabase"]
    addSong -->|"сохраняет песню"| db
    addSong -->|"выбор и копирование аудио/обложки"| fileStorage["FilePicker\nApplication Documents"]

    playerScreen -->|"список песен"| db
    playlistDetail -->|"playQueue()"| controller["PlayerController\nfeatures/player/player.dart"]
    playerScreen -->|"управление плеером"| controller
    controller -->|"play / pause / next / prev"| audioPlayer["AudioPlayer · audioplayers"]
    controller -->|"увеличивает счётчик прослушиваний"| db
    playerScreen --> songCover["SongCover"]
    playlistDetail --> songCover

    subgraph database["Схема Drift · data/database.dart"]
        authors["Authors\nid, name"]
        songs["Songs\nid, songName, authorId,\naudioPath, coverPath, listensAll"]
        playlistsTable["Playlists\nid, name, coverPath, createdAt"]
        playlistSongs["PlaylistSongs\nplaylistId, songId, position\nPK: playlistId + songId"]
        authors -->|"1 : N · authorId"| songs
        playlistsTable -->|"1 : N · playlistId"| playlistSongs
        songs -->|"1 : N · songId"| playlistSongs
    end
    db --- database
```

## Getting Started
