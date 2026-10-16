import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../consts/constants.dart';
import '../consts/notifiers.dart';

import 'songs.dart';


// GETTING A LIST OF SONGS FROM A CONST VALUENOTIFIER
Future<void> initLoadSongsList() async {
  final prefs = await SharedPreferences.getInstance();

  final jsonString = prefs.getString(KConstant.loadedSongsKey);
  if (jsonString == null) return;

  final List<dynamic> decoded = jsonDecode(jsonString);

  loadedSongsNotifier.value = decoded.map((e) => Song.fromJson(e)).toList();
}


Future<void> initLoadCurrSong() async {
  final prefs = await SharedPreferences.getInstance();
  currentSongNotifier.value = prefs.getInt(KConstant.currentSongKey);
}


// loading time in ms that a song has been played for
Future<void> initLoadTimePlayed() async {
  final prefs = await SharedPreferences.getInstance();
  timePlayedNotifier.value = prefs.getInt(KConstant.timePlayedKey);
}