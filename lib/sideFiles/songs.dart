import 'dart:typed_data';
import 'dart:convert';

// SAVING ALL THE SONGS IN A JSON FORMAT SO THAT IN CAN BE SAVED BY A VALUE NOTIFIER THINGY
class Song {
  final String name;
  final String artist;
  final Uint8List? cover;
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
      'cover': cover == null ? null : base64Encode(cover!)
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      name: json['name'],
      artist: json['artist'],
      path: json['path'],
      isPlaying: json['isPlaying'],
      cover: json['cover'] == null
        ? null
        : base64Decode(json['cover'] as String)
    );
  }
}