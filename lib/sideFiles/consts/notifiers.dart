import 'package:flutter/material.dart';
import '../songs.dart';


ValueNotifier<bool> isLightModeNotifier = ValueNotifier(false); // whether the theme mode is light or dark
ValueNotifier<bool> isFirstView = ValueNotifier(true); // whether to open a main menu page or a catalogue page
final ValueNotifier<List<Song>> loadedSongsNotifier = ValueNotifier<List<Song>>([]); // saving all the songs loaded by a user