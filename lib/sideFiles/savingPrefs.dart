import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../consts/constants.dart';
import '../consts/notifiers.dart';



// SAVING PREFS OF OUR BACKGROUND COLOUR
void saveThemeColour() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(KConstant.themeModeKey, isLightModeNotifier.value);
}

// SAVING NEW SONGS THAT HAVE JUST BEEN LOADED IN
Future<void> saveAllSongs() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    KConstant.loadedSongsKey,
    jsonEncode(loadedSongsNotifier.value.map((song) => song.toJson()).toList())
  );
}


Future<void> saveCurrSong(int? currentSongIndex) async {
  final prefs = await SharedPreferences.getInstance();

  if (currentSongIndex == null || currentSongIndex < 0) { // dont allow the index to be < 0
    await prefs.remove(KConstant.currentSongKey);
  }
  else{
    await prefs.setInt(
      KConstant.currentSongKey,
      currentSongIndex
    );
  }
}


// saving time that a song's been played for in ms
Future<void> saveTimePlayed() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt(
    KConstant.timePlayedKey,
    timePlayedNotifier.value
  );
}

Future<void> saveScrollBarPos(double x) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(
    KConstant.scrollBarPosKey,
    x
  );
}
