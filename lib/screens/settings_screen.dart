// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeController controller;
  const SettingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Appearance'),
            subtitle: Text('Choose how Playlist City looks'),
          ),
          RadioListTile<ThemeChoice>(
            title: const Text('Use device theme'),
            subtitle: const Text('Match your phone’s light/dark setting'),
            value: ThemeChoice.system,
            groupValue: controller.choice,
            onChanged: (v) => controller.setChoice(v!),
          ),
          RadioListTile<ThemeChoice>(
            title: const Text('Light'),
            value: ThemeChoice.light,
            groupValue: controller.choice,
            onChanged: (v) => controller.setChoice(v!),
          ),
          RadioListTile<ThemeChoice>(
            title: const Text('Dark'),
            value: ThemeChoice.dark,
            groupValue: controller.choice,
            onChanged: (v) => controller.setChoice(v!),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
