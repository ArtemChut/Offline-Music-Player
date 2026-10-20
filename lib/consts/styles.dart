import 'package:flutter/material.dart';
import 'package:music_player/CataloguePage/SongsCataloguePage.dart';
import 'package:music_player/PlaylistsPage.dart';

import 'package:music_player/consts/notifiers.dart';
import 'package:music_player/sideFiles/importFiles.dart';
import 'package:music_player/sideFiles/savingPrefs.dart';

import '../SettingsPage.dart';


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


// CLASSIC APPBAR
class customAppBar extends StatelessWidget implements PreferredSizeWidget {
  const customAppBar({super.key});

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
            children: [
              IconButton(
                style: IconButtonStyles.iconButton,
                onPressed: () async {
                  isLightModeNotifier.value = !isLightModeNotifier.value;
                  saveThemeColour();
                },
                icon: Icon(
                  isLightMode ? Icons.light_mode : Icons.dark_mode,
                ),
              ),

              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: !isLightMode
                      ? const Color.fromARGB(255, 44, 37, 56)
                      : const Color.fromARGB(255, 151, 224, 189),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  style: IconButtonStyles.iconButton,
                  hoverColor: Colors.transparent,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return const PlaylistsPage();
                    },));
                  },
                  icon: const Icon(Icons.playlist_play_rounded),
                ),
              ),

              IconButton(
                style: IconButtonStyles.iconButton,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
              ),
            ],
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
          case 4:
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SettingsPage();
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
          icon: Icon(Icons.playlist_play_rounded),
          label: 'Playlists',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_chart_rounded),
          label: 'Statistics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

