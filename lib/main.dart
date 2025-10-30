import 'package:flutter/material.dart';
import 'package:playlist_city/state/playlist_state.dart';
import 'package:playlist_city/theme/theme_controller.dart';
import 'package:playlist_city/theme/app_theme.dart'; // <-- add this
import 'package:playlist_city/screens/home_page.dart';
import 'package:playlist_city/screens/import_page.dart';
import 'package:playlist_city/screens/editor_page.dart';
import 'package:playlist_city/screens/player_page.dart';
import 'package:playlist_city/screens/export_page.dart';
import 'package:playlist_city/screens/settings_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  await themeController.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlaylistState()..init()),
        ChangeNotifierProvider(create: (_) => themeController),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      title: 'Playlist City',
      debugShowCheckedModeBanner: false,
      themeMode: themeController.mode,
      theme: AppTheme.light(),   // <-- use centralized theme
      darkTheme: AppTheme.dark(),// <-- "
      initialRoute: '/home',
      routes: {
        '/home': (_) => const HomePage(),
        '/import': (_) => const ImportPage(),
        '/editor': (_) => const EditorPage(),
        '/player': (_) => const PlayerPage(),
        '/export': (_) => const ExportPage(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
