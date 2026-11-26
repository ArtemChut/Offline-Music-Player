import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/consts/styles.dart';
import 'package:music_player/sideFiles/changingSongProps.dart';

import '../sideFiles/playlists.dart';

Playlist playlist = Playlist(name: "");


// GETS A VALUE FROM AN INPUT FIELD (NAME OF AN ALBUM)
final TextEditingController playlistNameController  = TextEditingController();

Center createPlaylist(
  double screenWidth,
  Color? cardColour,
  Color? mainCardColour,
  screenHeight,
  void Function(VoidCallback) setState
) {
  return Center(
    child: Container(
      width: screenWidth / 3,
      height: screenWidth / 3,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cardColour,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: screenWidth * 0.07),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // adding cover to a playlist (image)
            
            MouseRegion(
              cursor: SystemMouseCursors.click, // changing a cursor to a pointer
              child: GestureDetector(
                onTap:() async {
                  await changeAlbumCover(playlist, setState);
                },
                child: Container(
                  height: screenWidth / 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: mainCardColour,
                  ),
                  alignment: Alignment.center,
                        
                  child: displayAlbumCover(playlist, false, screenHeight, screenWidth / 10, "playlist")
                ),
              ),
            ),


            SizedBox(height: screenWidth*0.02), // a little margin
            // giving name of a playlist
            TextField(
              controller: playlistNameController,
              maxLength: 24,
              enableSuggestions: true,
              decoration: InputDecoration(
                hintText: "name of your playlist..",
                border: OutlineInputBorder(),
              )
            )
            ],
        ),
      ),
    ),
  );
}
