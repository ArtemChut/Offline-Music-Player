import 'package:flutter/material.dart';

import '../../consts/styles.dart';


/* - - - - - - - - 
2 variations of cards, a normal one with song name, artist name, album cover and a song currently playing which has skip/pause buttons and other info such as length of a song and such 
                                                        - - - - - - - - - - - */
Padding PlaylistCard( void Function(VoidCallback) setState,
  {albumCoverSize, cardColour, cardWidth, screenHeight, selectedCardColour, playlist, scrollController}

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


            displayAlbumCover(playlist, false, screenHeight, albumCoverSize, "playlist"),
            
            Text("Total of ${playlist.songsInside.length} songs inside")
          ],
        )
        ),
    ],),
  );
}
