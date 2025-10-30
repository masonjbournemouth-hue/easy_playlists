import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';
import '../models/track.dart';

class PlaylistState extends ChangeNotifier {
  final List<Track> _tracks = [];
  String _title = 'Untitled Playlist';
  bool shuffle = false;

  List<Track> get tracks => List.unmodifiable(_tracks);
  String get title => _title;

  Future<void> init() async {
    await _loadLastSession();
  }

  void setTitle(String t) {
    _title = t.trim().isEmpty ? 'Untitled Playlist' : t.trim();
    notifyListeners();
  }

  void addTracks(List<Track> list) {
    _tracks.addAll(list);
    notifyListeners();
  }

  void removeAt(int index) {
    _tracks.removeAt(index);
    notifyListeners();
  }

  void move(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _tracks.removeAt(oldIndex);
    _tracks.insert(newIndex, item);
    notifyListeners();
  }

  void clear() {
    _tracks.clear();
    notifyListeners();
  }

  Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode({
      'title': _title,
      'tracks': _tracks.map((e) => e.toJson()).toList(),
    });
    await prefs.setString('last_session', jsonStr);
  }

  Future<void> _loadLastSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('last_session');
    if (jsonStr != null) {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      _title = data['title'] as String? ?? 'Untitled Playlist';
      final items = (data['tracks'] as List?) ?? [];
      _tracks
        ..clear()
        ..addAll(items
            .map((e) => Track.fromJson(Map<String, dynamic>.from(e)))
            .toList());
      notifyListeners();
    }
  }
}
