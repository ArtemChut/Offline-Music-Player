import 'package:flutter/material.dart';

import 'songInteraction.dart';

import '../SongsCataloguePage.dart';

bool changed = false;

// CHECKING IF SONG HAS COME TO AN END
StreamBuilder checkSongEnded(void Function(VoidCallback) setState) {
  return // CHECKING IF SONG HAS COME TO AN END
    StreamBuilder<Duration> ( 
      stream: audioPlayer.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
  
        if (audioPlayer.duration != null) {
          if (position >= audioPlayer.duration! && !changed && position.toString() != "0:00:00.000000") {
            changed = true;
  
            WidgetsBinding.instance.addPostFrameCallback((_) { // play the next song in the queue (first one if out of songs)
              prevNextSong("next", setState);
            });
          }
  
          if (position < audioPlayer.duration!) {
            changed = false;
          }
        }
  
        return const SizedBox(); // must return something so add an empty box
      },
    );
}