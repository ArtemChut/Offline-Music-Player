import 'package:flutter/material.dart';
import 'importFiles.dart';
import '../SettingsPage.dart';
import '../SongsCataloguePage.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });
  

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) async {
        switch (index){
          case 0:
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SongsCataloguePage();
            },));
          case 1:
            await loadSongs();
          case 2:
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
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
