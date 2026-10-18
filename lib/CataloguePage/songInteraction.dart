import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_player/consts/notifiers.dart';

import 'removingFaultyPaths.dart';
import 'SongsCataloguePage.dart';

import '../sideFiles/savingPrefs.dart';


Future<void> changeSong(int index, ValueNotifier loadedSongsNotifier) async {  

  int direction = 1;
  if (currentSongIndex != null){
    direction = index > currentSongIndex! ? 1 : -1;
  }

  
  // scrolling our songs carousel 

  scrollController.jumpTo(
    (scrollController.offset + direction * cardWidth).clamp(
      0.0,
      scrollController.position.maxScrollExtent,
    ),
  );



  // stopping the previous song
  if (currentSongIndex != null){
    loadedSongsNotifier.value[currentSongIndex!].isPlaying = false;
  }

  // saving a new song that's currently playing
  currentSongIndex = index;
  await saveCurrSong(currentSongIndex);


  final song = loadedSongsNotifier.value[songsCount-1-index]; // opposite side of a list as we display songs right to left
  song.isPlaying = true;

  try{
    if (await File(song.path).exists()){
      await audioPlayer.setFilePath(song.path);

      await audioPlayer.play();
      await audioPlayer.play(); // prevents a bug when launching a song for the very first time 
    }
    
    // deletes a song from out storage if the path is faulty
    // GOTTA ADD A POP UP ERROR NOTIF THAT PATH WAS DESTROYED
    else{
      await removeFaultySongs();
    }
  } 
  on Exception{
    // ignore if too many songs are being skipped in 1 second
  }
}


void playPauseSong(song, bool playing) async {
  if (await File(song.path).exists()){
    if (playing){
      await audioPlayer.play();
    }
    else{
      await audioPlayer.pause();
    }
  }

  // deletes a song from out storage if the path is faulty
  // GOTTA ADD A POP UP ERROR NOTIF THAT PATH WAS DESTROYED
  else{
    await removeFaultySongs();
  }
}

void prev_next_song(String type, void Function(VoidCallback) setState) async {
  // if skipping to the next song
  if (type == "next"){
    await changeSong((currentSongIndex! + 1) % songsCount, loadedSongsNotifier);
    await saveCurrSong(currentSongIndex);

    // update the visuals (pause/play buttons + current song card)
    setState(() { });
  }

  // if going bck to the previous song
  else{
    if (currentSongIndex! > 0){ // dont allow to go out of bounds (-1...)
      await changeSong(currentSongIndex! - 1, loadedSongsNotifier);
      await saveCurrSong(currentSongIndex);
      
      // update the visuals (pause/play buttons + current song card)
      setState(() { });
    }

    // if a user clicks on a "previous song" button when it's already the first song then just re-start it
    else{
      await changeSong(currentSongIndex!, loadedSongsNotifier);

      // update the visuals (pause/play button)
      setState(() { });
    }
  }
}


Duration? position;
// formats time that a song's been played for so it looks e.g. like 01.00
String formatDuration(String time){
  final String seconds = time.substring(5,7);
  final String minutes = time.substring(2,4);
  return "${minutes}.${seconds}";
}
