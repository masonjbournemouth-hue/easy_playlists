import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/playlist_state.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlaylistState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Playlist')),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.tracks.length,
        onReorder: (oldIndex, newIndex) =>
            context.read<PlaylistState>().move(oldIndex, newIndex),
        itemBuilder: (_, i) {
          final track = state.tracks[i];
          return Dismissible(
            key: ValueKey(track.path),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => context.read<PlaylistState>().removeAt(i),
            child: ListTile(
              leading: const Icon(Icons.drag_indicator),
              title: Text(track.name),
              subtitle: Text(track.path),
              trailing: const Icon(Icons.reorder),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<PlaylistState>().clear(),
        icon: const Icon(Icons.clear_all),
        label: const Text('Clear All'),
      ),
    );
  }
}
