import 'dart:typed_data';

class Playlist {
  String name;
  Uint8List? cover;
  String? alteredAlbumCoverPath;
  List<int>? songsInside;

  Playlist({
    required this.name,
    this.cover,
    this.alteredAlbumCoverPath,
    this.songsInside
  });

  // CONVERT PLAYLIST INTO JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cover': cover?.toList(),
      'alteredAlbumCoverPath': alteredAlbumCoverPath,
      'songsInside': songsInside,
    };
  }

  // CREATE PLAYLIST FROM JSON
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'],
      cover: json['cover'] != null
          ? Uint8List.fromList(List<int>.from(json['cover']))
          : null,
      alteredAlbumCoverPath: json['alteredAlbumCoverPath'],
      songsInside: json['songsInside'] != null
          ? List<int>.from(json['songsInside'])
          : null,
    );
  }
}