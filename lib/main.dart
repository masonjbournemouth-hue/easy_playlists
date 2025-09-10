// lib/main.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  await themeController.load();

  runApp(PlaylistCityApp(themeController: themeController));
}

class PlaylistCityApp extends StatefulWidget {
  final ThemeController themeController;
  const PlaylistCityApp({super.key, required this.themeController});

  @override
  State<PlaylistCityApp> createState() => _PlaylistCityAppState();
}

class _PlaylistCityAppState extends State<PlaylistCityApp> {
  @override
  void initState() {
    super.initState();
    widget.themeController.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.themeController.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playlist City',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: widget.themeController.themeMode,
      home: HomeScreen(themeController: widget.themeController),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final ThemeController themeController;
  const HomeScreen({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist City'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SettingsScreen(controller: themeController),
              ));
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to Playlist City',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
