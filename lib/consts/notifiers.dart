import 'package:flutter/material.dart';
import '../sideFiles/songs.dart';


ValueNotifier<bool> isLightModeNotifier = ValueNotifier(false); // whether the theme mode is light or dark
ValueNotifier<bool> isFirstView = ValueNotifier(true); // whether to open a main menu page or a catalogue page
ValueNotifier<List<Song>> loadedSongsNotifier = ValueNotifier<List<Song>>([]); // saving all the songs loaded by a user
ValueNotifier<int?> currentSongNotifier = ValueNotifier<int?>(null); // index of a song currently playing
ValueNotifier<int?> timePlayedNotifier = ValueNotifier(null); // time in ms that a song's been played for
