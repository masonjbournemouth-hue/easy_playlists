import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/playlist_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlaylistState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Playlist City')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Title + quick edit
          Text(
            'Your Playlist',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.title,
            decoration: const InputDecoration(
              labelText: 'Playlist Title',
            ),
            onChanged: (v) => context.read<PlaylistState>().setTitle(v),
          ),
          const SizedBox(height: 20),

          // Quick action cards
          _ActionCard(
            icon: Icons.file_open,
            iconBg: Theme.of(context).colorScheme.primaryContainer,
            title: 'Import Songs',
            subtitle: 'Add MP3, WAV, AAC, FLAC',
            onTap: () => Navigator.pushNamed(context, '/import'),
          ),
          _ActionCard(
            icon: Icons.playlist_play,
            iconBg: Theme.of(context).colorScheme.secondaryContainer,
            title: 'Edit Playlist',
            subtitle: 'Reorder or remove tracks',
            onTap: () => Navigator.pushNamed(context, '/editor'),
          ),
          _ActionCard(
            icon: Icons.play_arrow,
            iconBg: Theme.of(context).colorScheme.tertiaryContainer,
            title: 'Play',
            subtitle: 'Auto play in order or shuffle',
            onTap: () => Navigator.pushNamed(context, '/player'),
          ),
          _ActionCard(
            icon: Icons.save_alt,
            iconBg: Theme.of(context).colorScheme.primaryContainer,
            title: 'Export',
            subtitle: 'Save as M3U / M3U8 / PLS',
            onTap: () => Navigator.pushNamed(context, '/export'),
          ),
          _ActionCard(
            icon: Icons.settings,
            iconBg: Theme.of(context).colorScheme.secondaryContainer,
            title: 'Settings',
            subtitle: 'Theme and preferences',
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),

          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.read<PlaylistState>().saveSession(),
            icon: const Icon(Icons.save),
            label: const Text('Save Progress'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onIconBg = Theme.of(context).colorScheme.onPrimaryContainer;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: onIconBg, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
