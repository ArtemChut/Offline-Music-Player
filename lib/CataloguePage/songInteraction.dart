import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'SongsCataloguePage.dart';

import '../sideFiles/savingPrefs.dart';


Future<void> changeSong(int index, AudioPlayer _player, ValueNotifier loadedSongsNotifier) async {  
  // PURELY FOR DEBUGGING PURPOSES
  if (index == currentSongIndex){
    await _player.stop();
    return;
  }

  // stopping the previous song
  if (currentSongIndex != null){
    loadedSongsNotifier.value[currentSongIndex!].isPlaying = false;
  }

  // saving a new song that's currently playing
  currentSongIndex = index;
  await saveCurrSong(currentSongIndex);


  final song = loadedSongsNotifier.value[songsCount-1-index]; // opposite side of a list as we display songs right to left

  try{
    if (await File(song.path).exists()){
      await _player.setFilePath(song.path);

      await _player.play();
      await _player.play(); // prevents a bug when launching a song for the very first time 
    }
    
    else{

    }
  } 
  on PlayerInterruptedException{
    // ignore if too many songs are being skipped in 1 second
  }
}


Duration? position;
// formats time that a song's been played for so it looks e.g. like 01.00
String formatDuration(String time){
  final String seconds = time.substring(5,7);
  final String minutes = time.substring(2,4);
  return "${minutes}.${seconds}";
}
