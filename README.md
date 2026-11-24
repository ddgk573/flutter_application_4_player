# Wave Player

Flutter-приложение с нижней навигацией между экранами плейлистов,
плеера и настроек.

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

    home --> tabState["currentTab\ncore/app_state.dart\nиндексы: 0 Playlists, 1 Player, 2 Settings"]
    tabState --> nav["BottomNavigationBar"]
    nav -->|"меняет выбранную вкладку"| tabState
    home --> screenList["_screen[currentTab]"]
    screenList --> playlists["PlayListScreen"]
    screenList --> playerScreen["PlayerScreen"]
    screenList --> settings["SettingsScreen"]
    settings -->|"читает и меняет"| themeNotifier

    playlists -->|"открывает"| playlistDetail["PlaylistDetailScreen"]
    playlists -->|"создаёт песню"| addSong["AddSongDialog"]
    playlistDetail -->|"добавляет песню в плейлист"| addSong
    playlistDetail -->|"список песен и плейлистов"| db["db · AppDatabase"]
    addSong -->|"сохраняет песню"| db
    addSong -->|"выбор и копирование аудио/обложки"| fileStorage["FilePicker\nApplication Documents"]
    addSong -->|"читает название, автора и встроенную обложку"| metadata["metadata_reader.dart\nIsolate"]
    metadata -->|"SongMetadata"| addSong

    playerScreen -->|"список песен"| db
    playlistDetail -->|"playQueue()"| controller["PlayerController\nfeatures/player/player.dart\nSingleton"]
    playerScreen -->|"управление плеером"| controller
    controller -->|"play / pause / next / prev"| audioPlayer["AudioPlayer · audioplayers"]
    controller -->|"увеличивает счётчик прослушиваний"| db
    controller -->|"текущая песня и очередь"| playerScreen
    controller -->|"позиция и длительность"| seekBar["SeekBar"]
    seekBar -->|"seek()"| controller
    playerScreen --> songCover["SongCover"]
    playlistDetail --> songCover
    addSong --> songCover

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
