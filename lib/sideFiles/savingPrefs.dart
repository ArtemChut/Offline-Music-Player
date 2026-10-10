import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'consts/constants.dart';
import 'consts/notifiers.dart';


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