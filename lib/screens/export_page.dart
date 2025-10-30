import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../state/playlist_state.dart';

enum ExportFormat { m3u, m3u8, pls }

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  ExportFormat format = ExportFormat.m3u8;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlaylistState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Export Playlist')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<ExportFormat>(
              value: format,
              items: const [
                DropdownMenuItem(value: ExportFormat.m3u, child: Text('M3U')),
                DropdownMenuItem(value: ExportFormat.m3u8, child: Text('M3U8 (UTF-8)')),
                DropdownMenuItem(value: ExportFormat.pls, child: Text('PLS')),
              ],
              onChanged: (v) => setState(() => format = v ?? ExportFormat.m3u8),
              decoration: const InputDecoration(
                labelText: 'Format',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.save_alt),
              label: const Text('Export'),
              onPressed: () async {
                final state = context.read<PlaylistState>();

                // Tiny countdown: base 2s + 0.2s per track, clamped to [2..6] seconds.
                final seconds = (2 + (state.tracks.length * 0.2)).clamp(2, 6).toInt();

                // Start export immediately.
                final exportFuture = _export(state);

                // Show countdown dialog while export runs.
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) {
                    int remaining = seconds;
                    Timer? t;
                    return StatefulBuilder(
                      builder: (ctx, setState) {
                        t ??= Timer.periodic(const Duration(seconds: 1), (_) {
                          if (remaining <= 1) {
                            t?.cancel();
                            Navigator.of(ctx).pop(); // close dialog
                          } else {
                            remaining -= 1;
                            setState(() {});
                          }
                        });
                        final progress = (seconds - remaining) / seconds;
                        return AlertDialog(
                          title: const Text('Exporting playlist…'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LinearProgressIndicator(value: progress == 0 ? null : progress),
                              const SizedBox(height: 12),
                              Text('Finishing in ~${remaining}s'),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );

                // Ensure export finished (wait if still writing).
                final file = await exportFuture;

                if (!mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Saved: ${file.path}')));

                await Share.shareXFiles([XFile(file.path)],
                    text: 'Playlist City – ${state.title}');
              },
            ),
            const SizedBox(height: 12),
            const Text('Tip: You can copy the exported file to USB or share it to other devices.'),
          ],
        ),
      ),
    );
  }

  Future<File> _export(PlaylistState state) async {
    final dir = await getApplicationDocumentsDirectory();
    final safeTitle = state.title.replaceAll(RegExp(r'[^A-Za-z0-9 _-]'), '_');
    late final String content;
    late final String ext;

    switch (format) {
      case ExportFormat.m3u:
        ext = 'm3u';
        content = state.tracks.map((t) => t.path).join('\n');
        break;
      case ExportFormat.m3u8:
        ext = 'm3u8';
        content = '#EXTM3U\n' + state.tracks.map((t) => t.path).join('\n');
        break;
      case ExportFormat.pls:
        ext = 'pls';
        final buffer = StringBuffer('[playlist]\n');
        for (var i = 0; i < state.tracks.length; i++) {
          buffer.writeln('File${i + 1}=${state.tracks[i].path}');
          buffer.writeln('Title${i + 1}=${state.tracks[i].name}');
          buffer.writeln('Length${i + 1}=-1'); // optional: compute durations with just_audio later
        }
        buffer
          ..writeln('NumberOfEntries=${state.tracks.length}')
          ..writeln('Version=2');
        content = buffer.toString();
        break;
    }

    final file = File('${dir.path}/$safeTitle.$ext');
    return file.writeAsString(content);
  }
}
