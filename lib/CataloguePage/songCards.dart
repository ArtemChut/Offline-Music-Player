import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../consts/styles.dart';


/* - - - - - - - - 
2 variations of cards, a normal one with song name, artist name, album cover and a song currently playing which has skip/pause buttons and other info such as length of a song and such 
                                                        - - - - - - - - - - - */
Padding songCard (
  int index, int? currentSongIndex, selectedCardColour, cardColour, cardWidth, song, albumCoverSize, double screenHeight, currentSong
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


            // CHECKING WHETHER A SONG HAS AN ALBUM COVER, IF YES LOAD IT, OTHERWISE - LOAD A BASIC PHOTO
            song.cover==null ? // if a song has no album cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SvgPicture.asset("assets/images/heart.svg",
              width: currentSong ? screenHeight*0.8*0.4 : albumCoverSize) // scale down a bit if it's a currently selected song
            )
            : // else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(song.cover!,
              width: currentSong ? albumCoverSize*0.8 : albumCoverSize) // scale down a bit if it's a currently selected song
            ),
            

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

        if (currentSong)
          // extra stats
          Expanded(
            flex: 20,
            child: SizedBox(
            width: double.maxFinite,
        
            child: Card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
              
                children: [
                  IconButtonStyles.trasnferIconButton(
                    action: () {print("prev");}, 
                    icon: Icon(Icons.skip_previous_rounded)
                  ),

                  IconButtonStyles.trasnferIconButton(
                    action: () {print("stop/play");}, 
                    icon: Icon(song.isPlaying ? Icons.pause : Icons.play_arrow_rounded)
                  ),
              
                  IconButtonStyles.trasnferIconButton(
                    action: () {print("next");}, 
                    icon: Icon(Icons.skip_next_rounded)
                  ),
                ],
              ),
            ),
          )
          )
    ],),
  );
}