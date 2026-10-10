import 'dart:io';
import 'dart:convert';

import 'consts/constants.dart';
import 'consts/notifiers.dart';
import 'songs.dart';
import 'savingPrefs.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:shared_preferences/shared_preferences.dart';



// GETTING A LIST FROM A CONST VALUENOTIFIER
Future<void> initLoadNotifier() async {
  final prefs = await SharedPreferences.getInstance();

  final jsonString = prefs.getString(KConstant.loadedSongsKey);
  if (jsonString == null) return;

  final List<dynamic> decoded = jsonDecode(jsonString);

  loadedSongsNotifier.value = decoded.map((e) => Song.fromJson(e)).toList();
}


String songName(String name) {
  // removing file type from end of the file name thats being displayed
  while (!name.endsWith(".")) {
    name = name.substring(0, name.length - 1);
  }
  return name.substring(0, name.length - 1);
}

Future<void> loadSongs() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.audio,
    allowMultiple: true,
  );

  if (result == null) return;

  List<Song> newSongs = [];

  for (final song in result.files) {
    if (song.path == null) return;


    final metadata = await MetadataRetriever.fromFile(File(song.path!));
    
    // changing the name of an artist to ?*8 if it's null (for some reason simple .isNotEmpty doesnt work)
    String? artist;
    if (metadata.trackArtistNames != null && metadata.trackArtistNames!.join(", ").length > 0){
      artist = metadata.trackArtistNames!.join(", ");
    }
    else{
      artist = "Unknown artist";
    }
    

    final Song songObj = Song(
      name: songName(song.name),
      artist: artist,
      cover: metadata.albumArt,
      path: song.path!
    );

    newSongs.add(songObj);
  }

  
  loadedSongsNotifier.value = [
    ...loadedSongsNotifier.value,
    ...newSongs,
  ];

  await saveAllSongs();
}
