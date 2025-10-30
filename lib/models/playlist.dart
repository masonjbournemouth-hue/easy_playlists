import 'track.dart';

class PlaylistModel {
  final String title;
  final List<Track> tracks;

  PlaylistModel({required this.title, required this.tracks});

  Map<String, dynamic> toJson() => {
        'title': title,
        'tracks': tracks.map((t) => t.toJson()).toList(),
      };

  factory PlaylistModel.fromJson(Map<String, dynamic> json) => PlaylistModel(
        title: json['title'] as String,
        tracks: (json['tracks'] as List)
            .map((e) => Track.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
