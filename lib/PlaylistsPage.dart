import 'package:flutter/material.dart';

import 'package:music_player/SettingsPage.dart';

import 'package:music_player/consts/notifiers.dart';
import 'package:music_player/consts/styles.dart';

import 'package:music_player/sideFiles/savingPrefs.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: customAppBar(elements: [
        IconButton(
          style: IconButtonStyles.iconButton,
          onPressed: () async {
            isLightModeNotifier.value = !isLightModeNotifier.value;
            saveThemeColour();
          },
          icon: Icon(
            isLightModeNotifier.value ? Icons.light_mode : Icons.dark_mode,
          ),
        ),
        IconButton(
          style: IconButtonStyles.iconButton,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const SettingsPage();
                }
              ),
            );
          },
          icon: const Icon(Icons.settings),
        ),
      ]),

      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          vertical: screenHeight*0.15,
          horizontal: screenWidth*0.1
        ),
        child: Center(
      
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: screenWidth*0.8,
                height: screenHeight*0.7,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ),
              )
          ],)
        ),
      ),
    );
  }
}