import 'dart:typed_data';
import 'dart:convert';

class Song {
  String name;
  String artist;
  Uint8List? cover;
  final String path;
  bool isPlaying;

  Song({
    required this.path,
    required this.name,
    required this.artist,
    this.cover,
    this.isPlaying = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'artist': artist,
      'path': path,
      'isPlaying': isPlaying,
      'cover': cover == null
          ? null
          : base64Encode(cover!),
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      name: json['name'] as String,
      artist: json['artist'] as String,
      path: json['path'] as String,
      isPlaying: json['isPlaying'] as bool? ?? false,
      cover: json['cover'] == null
          ? null
          : base64Decode(json['cover'] as String),
    );
  }
}
