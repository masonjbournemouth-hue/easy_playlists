// Easy Playlists – full minimal working app (create, save, play)

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const EasyPlaylistsApp());

class EasyPlaylistsApp extends StatelessWidget {
  const EasyPlaylistsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkGreen = const Color(0xFF1B5E20);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Easy Playlists',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: darkGreen,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: darkGreen,
          secondary: darkGreen,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: darkGreen,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(44),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark().copyWith(
          primary: darkGreen,
          secondary: darkGreen,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: darkGreen,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

/* ========================= Home ========================= */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<String>> _loadSavedPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('saved_playlists') ?? [];
  }

  Future<void> _deletePlaylist(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('saved_playlists') ?? [];
    list.remove(name);
    await prefs.setStringList('saved_playlists', list);
    await prefs.remove('playlist_$name');
    setState(() {});
  }

  Future<void> _exportM3U(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('playlist_$name');
    if (jsonStr == null) return;
    final paths = List<String>.from(jsonDecode(jsonStr));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name.m3u');
    await file.writeAsString(paths.join('\n'));
    await Share.shareXFiles([XFile(file.path)], text: 'Playlist exported: $name.m3u');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Easy Playlists')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePlaylistScreen()),
        ).then((_) => setState(() {})),
        label: const Text('New Playlist'),
        icon: const Icon(Icons.playlist_add),
      ),
      body: FutureBuilder<List<String>>(
        future: _loadSavedPlaylists(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(
              child: Text('No playlists yet.\nTap “New Playlist” to create one.', textAlign: TextAlign.center),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final name = items[i];
              return ListTile(
                title: Text(name),
                leading: const Icon(Icons.queue_music),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Export M3U',
                      icon: const Icon(Icons.download),
                      onPressed: () => _exportM3U(name),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deletePlaylist(name),
                    ),
                  ],
                ),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final jsonStr = prefs.getString('playlist_$name');
                  if (jsonStr == null) return;
                  final paths = List<String>.from(jsonDecode(jsonStr));
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerScreen(playlistName: name, songPaths: paths),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/* ========================= Create Playlist ========================= */

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _nameCtrl = TextEditingController();
  final List<File> _songs = [];

  Future<void> _pickSongs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'flac'],
      allowMultiple: true,
    );
    if (result == null) return;
    final newFiles = result.paths
        .whereType<String>()
        .map((p) => File(p))
        .where((f) => !_songs.any((s) => s.path == f.path))
        .toList();
    setState(() => _songs.addAll(newFiles));
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a name and add at least one song.')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_playlists') ?? [];
    if (!saved.contains(name)) {
      saved.add(name);
      await prefs.setStringList('saved_playlists', saved);
    }
    await prefs.setString('playlist_$name', jsonEncode(_songs.map((f) => f.path).toList()));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Playlist')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Playlist name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickSongs,
                    icon: const Icon(Icons.library_music),
                    label: const Text('Add Songs'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final f = _songs.removeAt(oldIndex);
                    _songs.insert(newIndex, f);
                  });
                },
                children: [
                  for (int i = 0; i < _songs.length; i++)
                    ListTile(
                      key: ValueKey(_songs[i].path),
                      title: Text(_songs[i].path.split(Platform.pathSeparator).last),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => _songs.removeAt(i)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save Playlist'),
            ),
          ],
        ),
      ),
    );
  }
}

/* ========================= Player ========================= */

class PlayerScreen extends StatefulWidget {
  final String playlistName;
  final List<String> songPaths;
  const PlayerScreen({super.key, required this.playlistName, required this.songPaths});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _player = AudioPlayer();
  int _index = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _load(_index);
  }

  Future<void> _load(int i) async {
    try {
      await _player.setFilePath(widget.songPaths[i]);
      await _player.play();
      setState(() => _isReady = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not play file:\n$e')));
    }
  }

  Future<void> _toggle() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    setState(() {});
  }

  Future<void> _next() async {
    if (_index < widget.songPaths.length - 1) {
      _index++;
      await _load(_index);
    }
  }

  Future<void> _prev() async {
    if (_index > 0) {
      _index--;
      await _load(_index);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.songPaths[_index].split(Platform.pathSeparator).last;
    return Scaffold(
      appBar: AppBar(title: Text(widget.playlistName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isReady) Text('Now Playing', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(iconSize: 36, icon: const Icon(Icons.skip_previous), onPressed: _prev),
                const SizedBox(width: 8),
                IconButton(
                  iconSize: 56,
                  icon: Icon(_player.playing ? Icons.pause_circle_filled : Icons.play_circle_fill),
                  onPressed: _toggle,
                ),
                const SizedBox(width: 8),
                IconButton(iconSize: 36, icon: const Icon(Icons.skip_next), onPressed: _next),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
