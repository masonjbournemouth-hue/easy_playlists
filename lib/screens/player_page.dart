import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../state/playlist_state.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final player = AudioPlayer();
  String? error;
  bool loading = true;

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = context.read<PlaylistState>();
    if (state.tracks.isEmpty) {
      setState(() {
        loading = false;
        error = 'No tracks to play.\nImport songs first.';
      });
      return;
    }

    try {
      final sources =
          state.tracks.map((t) => AudioSource.uri(Uri.file(t.path))).toList();
      final playlist = ConcatenatingAudioSource(children: sources);
      await player.setAudioSource(playlist);
      await player.setLoopMode(LoopMode.off);
      await player.setShuffleModeEnabled(state.shuffle);
      await player.play(); // auto-play
      setState(() {
        loading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Playback failed: $e';
      });
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlaylistState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Player')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          FilledButton(
                            onPressed: () async {
                              try {
                                await player.play();
                              } catch (e) {
                                _toast('Play error: $e');
                              }
                            },
                            child: const Icon(Icons.play_arrow),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () async {
                              try {
                                await player.pause();
                              } catch (e) {
                                _toast('Pause error: $e');
                              }
                            },
                            child: const Icon(Icons.pause),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () async {
                              try {
                                await player.seekToPrevious();
                              } catch (e) {
                                _toast('Skip previous error: $e');
                              }
                            },
                            icon: const Icon(Icons.skip_previous),
                          ),
                          IconButton(
                            onPressed: () async {
                              try {
                                await player.seekToNext();
                              } catch (e) {
                                _toast('Skip next error: $e');
                              }
                            },
                            icon: const Icon(Icons.skip_next),
                          ),
                          const Spacer(),
                          Switch(
                            value: state.shuffle,
                            onChanged: (v) async {
                              state.shuffle = v;
                              // ignore: use_build_context_synchronously
                              context.read<PlaylistState>().notifyListeners();
                              try {
                                await player.setShuffleModeEnabled(v);
                              } catch (e) {
                                _toast('Shuffle error: $e');
                              }
                            },
                          ),
                          const Text('Shuffle'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: state.tracks.length,
                          itemBuilder: (_, i) => ListTile(
                            leading: const Icon(Icons.music_note),
                            title: Text(state.tracks[i].name),
                            onTap: () async {
                              try {
                                await player.seek(Duration.zero, index: i);
                              } catch (e) {
                                _toast('Seek error: $e');
                              }
                            },
                          ),
                          separatorBuilder: (_, __) => const Divider(height: 1),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
