import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
import '../state/playlist_state.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlaylistState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Import Songs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select audio files to add to your playlist.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.file_open),
              label: const Text('Pick Files'),
              onPressed: () async {
                try {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    type: FileType.custom,
                    allowedExtensions: ['mp3', 'wav', 'aac', 'flac'],
                  );

                  if (result == null || result.files.isEmpty) {
                    _toast(context, 'No files selected');
                    return;
                  }

                  final tracks = result.files
                      .where((f) => f.path != null)
                      .map((f) => Track(path: f.path!, name: f.name))
                      .toList();

                  if (tracks.isEmpty) {
                    _toast(context, 'No supported files found');
                    return;
                  }

                  // ignore: use_build_context_synchronously
                  context.read<PlaylistState>().addTracks(tracks);
                  // ignore: use_build_context_synchronously
                  _toast(context, 'Added ${tracks.length} file(s)');
                } catch (e) {
                  _toast(context, 'Import failed: $e');
                }
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: state.tracks.isEmpty
                  ? const Center(
                      child: Text('No tracks yet. Use “Pick Files” to import.'),
                    )
                  : ListView.separated(
                      itemCount: state.tracks.length,
                      itemBuilder: (_, i) => ListTile(
                        leading: const Icon(Icons.music_note),
                        title: Text(state.tracks[i].name),
                        subtitle: Text(state.tracks[i].path),
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
