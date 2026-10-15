import 'package:flutter/material.dart';
import 'dart:io';
import 'consts/constants.dart';
import 'consts/notifiers.dart';
import 'sideFiles/savingPrefs.dart';
import 'sideFiles/songs.dart';
import 'SongsCataloguePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'sideFiles/loadNotifiers.dart';



Future<void> clearSongs() async {
  // Clear the in-memory song list
  loadedSongsNotifier.value = [];

  // Clear the saved JSON
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(KConstant.loadedSongsKey);
}

Future<void> clearCurr() async {
  currentSongNotifier.value = null;
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(KConstant.currentSongKey);
}



void adjustCurrSongIndex(index) async {
  // loading current curSongIndex
  initLoadCurrSong();
  currentSongIndex = currentSongNotifier.value;

  if (currentSongIndex == null) return;

  // if current song's index is > than deleted song's, then we decrement current song's index as a list is shorter now
  if (currentSongIndex! > index){
    currentSongIndex = currentSongIndex! - 1;
    await saveCurrSong(currentSongIndex);
  }
  // set cur song's index to null as current song is the same song that was just deleted
  else if (currentSongIndex == index){
    currentSongIndex = null;
    await saveCurrSong(currentSongIndex);
  }
}


// SETTING THE THEME OF OUR BACKGROUND
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  // CHECKING WHETHER IT'S A FIRST EVER LAUNCH BY A USER
  isFirstView.value = prefs.getBool(KConstant.firstViewKey) ?? true;

  //clearSongs(); // for debugging purposes
  //clearCurr();

  // loading a theme colour
  isLightModeNotifier.value = prefs.getBool(KConstant.themeModeKey) ?? false;

  
  // REMOVING A SONG IF PATH IS INVALID
  if (!isFirstView.value) {
    await initLoadSongsList();

    final songs = loadedSongsNotifier.value;
    final validSongs = <Song>[];

    for (final song in songs) {
      if (await File(song.path).exists()) {
        validSongs.add(song);
      }
      else{
        adjustCurrSongIndex(songs.indexOf(song));
      }
    }


    loadedSongsNotifier.value = validSongs;

    await saveAllSongs();
  }
  

  runApp(
    ValueListenableBuilder(
      valueListenable: isLightModeNotifier,
      builder: (context, value, child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
      
          themeMode: isLightModeNotifier.value ? ThemeMode.light : ThemeMode.dark,
      
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
      
          home: isFirstView.value ? const MainPage() : const SongsCataloguePage()
      );
    },
    )
  );
}



class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;


    return ValueListenableBuilder(
      valueListenable: isLightModeNotifier,
      builder: (context, isLightMode, child) {
        // APPBAR
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
        
            backgroundColor: !isLightMode ? const Color.fromARGB(255, 37, 31, 48) : const Color.fromARGB(255, 118, 226, 174),

            // everything inside the appbar
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // button allowing to change the theme colour
                IconButton(onPressed: () async {
                  isLightModeNotifier.value = !isLightModeNotifier.value;
                  saveThemeColour();
                },
                icon: Icon(isLightMode ? Icons.light_mode : Icons.dark_mode),
                ),

                Text("HELLO!!"),

                Icon(Icons.settings)
              ],  
            ),
          ),



          // MAIN BODY OF OUR MAIN MENU PAGE
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(17, 64, 35, 83),
                  borderRadius: BorderRadius.circular(40)
                ),
                width: screenWidth*0.6,
                height: screenHeight*0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                
                  Text(
                    "Welcome!",
                    style: TextStyle(
                      fontSize: 44,
                      fontFamily: "Times New Roman",
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.wavy,
                      decorationColor: const Color.fromARGB(255, 199, 68, 255)
                    )),
                
                  SvgPicture.asset(
                    "assets/images/heart.svg",
                    width: screenHeight * 0.5),
                  
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: FilledButton(
                      // OPENING A PAGE WITH ALL THE SONGS CURRENTLY IMPORTED (SHOULD BE EMPTY)
                      onPressed:() async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool(KConstant.firstViewKey, false);
                    
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                          return SongsCataloguePage();
                        },));
                      },
                      child:
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          "Enter heaven",
                          style: TextStyle(
                            fontSize: 28,
                            fontFamily: "Trebuchet MS"
                          )),
                      )),
                  )
                ],),
              ),
            )
          ),
        );
      },
    );
  }
}