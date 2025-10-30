class Track {
  final String path; // absolute file path
  final String name; // display name

  Track({required this.path, required this.name});

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
      };

  factory Track.fromJson(Map<String, dynamic> json) =>
      Track(path: json['path'] as String, name: json['name'] as String);
}
