import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:music_player/CataloguePage/SongsCataloguePage.dart';
import 'package:music_player/CataloguePage/sideFiled/songEndedHandling.dart';
import 'package:music_player/consts/notifiers.dart';

import 'package:music_player/sideFiles/savingPrefs.dart';

import '../../consts/styles.dart';
import 'songInteraction.dart';


/* - - - - - - - - 
2 variations of cards, a normal one with song name, artist name, album cover and a song currently playing which has skip/pause buttons and other info such as length of a song and such 
                                                        - - - - - - - - - - - */
Padding SongCard( void Function(VoidCallback) setState,
  {albumCoverSize, cardColour, cardWidth, currentSongIndex, index, screenHeight, selectedCardColour, song, currentSong}

) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // ALBUM COVER
        Expanded(
          flex: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            // a little margin to push album cover further down (closer to the center)
            SizedBox(height: screenHeight*0.6*0.08*0.6),


            displayAlbumCover(song, currentSong, screenHeight),
            

            // SONG NAME + ARTIST NAME
            Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // name of the song
              Texts.simpleSizedText(text: song.name, fontSize: nameSize),

              // artist name
              Texts.simpleSizedText(text: song.artist, fontSize: artistSize+4),

              // a little margin to push song name + artist name higher up (closer to the center)
              SizedBox(height: screenHeight*0.6*0.08*0.6)
            ],)
          ],
        )
        ),


        // IF A SONG IS A SONG CURRENTLY PLAYING ...
        if (currentSong)
          // THEN DISPLAY EXTRA STATS SUCH AS PAUSE/PLAY/NEXT/PREV BUTTONS
          Expanded(
            flex: 20,
            child: SizedBox(
            width: double.maxFinite,

            // everything about the song (time + interactive buttons such as pause/play)
            child: Card(
              color: isLightModeNotifier.value ? null : const Color.fromARGB(93, 40, 26, 44),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                  
                    children: [
                      // GO BACK TO A PREVIOUS SONG
                      IconButtonStyles.trasnferIconButton(
                        action: () {prevNextSong("prev", setState);}, 
                        icon: Icon(Icons.skip_previous_rounded)
                      ),

                      // PAUSE/PLAY A SONG
                      IconButtonStyles.trasnferIconButton(
                        action: () async {
                          setState((){
                            // change the icon to paused/playing
                            song.isPlaying = !song.isPlaying;
                          });
                  
                          // play/pause a song depending on the input
                          playPauseSong(song, song.isPlaying, index);
                  
                          await saveAllSongs();
                        }, 
                        icon: Icon(song.isPlaying ? Icons.pause : Icons.play_arrow_rounded),
                      ),
                  
                      // SKIP TO THE NEXT SONG IN THE QUEUE
                      IconButtonStyles.trasnferIconButton(
                        action: () {prevNextSong("next", setState);}, 
                        icon: Icon(Icons.skip_next_rounded)
                      ),
                    ],
                  ),


                  // DISPLAYS HOW MUCH OF A SONG'S BEEN PLAYED ALREADY & TOTAL TIME
                  StreamBuilder<Duration?>(
                    stream: audioPlayer.durationStream,
                    builder: (context, durationSnapshot) {
                      final duration = durationSnapshot.data;

                      return StreamBuilder<Duration>(
                        stream: audioPlayer.positionStream,
                        builder: (context, positionSnapshot) {
                          final position = positionSnapshot.data;

                          if (position != null && audioPlayer.processingState == ProcessingState.ready) {
                            timePlayedNotifier.value = position.inMilliseconds;
                            saveTimePlayed();
                          }


                          // DISPLAY HOW MUCH OF A SONG HAS BEEN PLAYED ALREADY + THE TOTAL LENGTH
                          try{
                            return Text(
                              "${formatDuration(position.toString())} : ${formatDuration(duration.toString())}",
                            );
                          }
                          on RangeError{
                            return const Text("-- : --");
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ),
        // GO TO THE NEXT SONG IF THE ONE PLAYING HAS ENDED
        checkSongEnded(setState)
    ],),
  );
}
