import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:music_player/CataloguePage/SongsCataloguePage.dart';
import 'package:music_player/PlaylistsPage.dart';

import 'package:music_player/consts/notifiers.dart';
import 'package:music_player/sideFiles/importSongs.dart';


const double nameSize = 26;
const double artistSize = 20;

// ICON BUTTON THTA AUTOMATICALLY SETS MOUSE CURSOR TO A POINTER
class IconButtonStyles {
  static final iconButton = IconButton.styleFrom(enabledMouseCursor: SystemMouseCursors.click);

  static IconButton trasnferIconButton ({VoidCallback? action, Icon? icon}) {
    return IconButton(
      style: iconButton,
      onPressed: () { action!(); },

    icon: icon!);
  } 
}


// TEXTS
class Texts {
  static Text simpleSizedText ({String? text, double? fontSize, String? font}) {
    return Text(
      textAlign: TextAlign.center,
      text!,
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: font
      ),
    );
  }
}



// CHECKING WHETHER A SONG HAS AN ALBUM COVER, IF YES LOAD IT, OTHERWISE - LOAD A BASIC PHOTO
ClipRRect displayAlbumCover(song, currentSong, screenHeight) {

  // if a song has no album cover
  if (song.cover == null && song.alteredAlbumCoverPath == null){
    // load a pre-installed img
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SvgPicture.asset("assets/images/musicNote.svg",
      colorFilter: ColorFilter.mode(
          isLightModeNotifier.value ?
          const Color.fromARGB(57, 0, 0, 0) : const Color.fromARGB(40, 194, 194, 194),
        BlendMode.srcIn,
      ),
      width: currentSong ? screenHeight*0.8*0.3 : albumCoverSize
    ) // scale down a bit if it's a currently selected song
    );
  }
  // if a song has an album cover
  else{
    // if the album cover wasn't manually put in by a user (not a path to an img)
    if (song.alteredAlbumCoverPath == null){
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(song.cover!,
          width: currentSong ? albumCoverSize*0.8 : albumCoverSize,
          height: currentSong ? albumCoverSize*0.8 : albumCoverSize,
          fit: BoxFit.cover, // make sure album cover img is a square
        ) // scale down a bit if it's a currently selected song
      );
    }
    // if it is a path to an img that was manually loaded by a user
    else{
      // if a path still exists (didnt get deleted)
      if (File(song.alteredAlbumCoverPath).existsSync()){
        // if an img is in .svg format
        if (song.alteredAlbumCoverPath.endsWith(".svg")){
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SvgPicture.file(File(song.alteredAlbumCoverPath!),
              width: currentSong ? albumCoverSize*0.8 : albumCoverSize,
            ) // scale down a bit if it's a currently selected song
          );
        }
        // if an img is in .jpg/.png format
        else{
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(song.alteredAlbumCoverPath!),
              width: currentSong ? albumCoverSize*0.8 : albumCoverSize,
              height: currentSong ? albumCoverSize*0.8 : albumCoverSize,
              fit: BoxFit.cover, // make sure user's image is a square
            ) // scale down a bit if it's a currently selected song
          );
        }
      }
      // if a path was deleted or just doesnt work
      else{
        // load a pre-installed img
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SvgPicture.asset("assets/images/musicNote.svg",
          colorFilter: ColorFilter.mode(
            isLightModeNotifier.value ?
          const Color.fromARGB(57, 0, 0, 0) : const Color.fromARGB(40, 194, 194, 194),
          BlendMode.srcIn,
        ),
          width: currentSong ? screenHeight*0.8*0.3 : albumCoverSize
        ) // scale down a bit if it's a currently selected song
        );
      }
    }
  }
}



// CLASSIC APPBAR
class customAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> elements; // all elements inside the appbar
  const customAppBar({super.key, required this.elements});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<bool>(
      valueListenable: isLightModeNotifier,
      builder: (context, isLightMode, child) {
        return AppBar(
          centerTitle: true,
          backgroundColor: !isLightMode
              ? const Color.fromARGB(255, 37, 31, 48)
              : const Color.fromARGB(255, 118, 226, 174),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: elements
          ),
        );
      },
    );
  }
}


// BOTTOM NAVIGATION BAR
class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });
  

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: isLightModeNotifier.value
        ? const Color.fromARGB(213, 213, 239, 225)
        : const Color.fromARGB(80, 31, 22, 37),

      selectedItemColor: isLightModeNotifier.value
        ? Colors.black
        : Colors.white,

      unselectedItemColor: isLightModeNotifier.value
        ? Colors.black54
        : Colors.white60,
      
      type: BottomNavigationBarType.fixed,

      showUnselectedLabels: true,
        
      currentIndex: currentIndex,
      onTap: (index) async {
        switch (index){
          case 0:
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const SongsCataloguePage();
            },));
          case 1:
            await loadSongs();
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const PlaylistsPage();
            },));
          case 3:
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const PlaylistsPage();
            },));
        }
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note_outlined),
          label: 'Catalogue',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.system_update_tv_rounded),
          label: 'Import',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music_outlined),
          label: 'Playlists',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_chart_rounded),
          label: 'Statistics',
        ),
      ],
    );
  }
}

