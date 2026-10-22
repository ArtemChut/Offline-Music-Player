import 'dart:io';

import '../../consts/notifiers.dart';

import '../../sideFiles/loadNotifiers.dart';
import '../../sideFiles/savingPrefs.dart';

import '../SongsCataloguePage.dart';

import '../../sideFiles/songs.dart';


void adjustCurrSongIndex(index) async {
  if (currentSongIndex == null) return;

  // if current song's index is < than deleted song's, then we decrement current song's index as a list is shorter now
  if (currentSongIndex == index){
    currentSongIndex = null;
    await saveCurrSong(currentSongIndex);

    // resetting the time back to 0 as if time > new song's length, an out of range error will occur
    timePlayedNotifier.value = 0;
    await saveTimePlayed();

  }
  // length of a list is reducing so we decrement our current song index
  else if (currentSongIndex! > index) {
    currentSongIndex = currentSongIndex! - 1;
    await saveCurrSong(currentSongIndex);
  }

}


// IS ONLY BEING USED WHEN AN APP IS FIRST LOADED AS THIS FUNCTION REMOVES ALL THE SONGS WHERE A PATH WAS CORRUPTED, NOT ONLY 1 SPECIFIC SONG
Future<void> removeFaultyPaths() async {
  // REMOVING A SONG IF PATH IS INVALID
  await initLoadSongsList();
  final songs = loadedSongsNotifier.value;

  await initLoadCurrSong();
  currentSongIndex = currentSongNotifier.value;

  final validSongs = <Song>[];

  int i = 0;
  for (final song in songs) {
    if (await File(song.path).exists()) {
      validSongs.add(song);
    }
    else{
      adjustCurrSongIndex(songs.length - 1 - i); // indexes are reversed as we display songs right to left
    }
    i += 1;
  }


  loadedSongsNotifier.value = validSongs;
  await saveAllSongs();

  songsCount = validSongs.length;
}
