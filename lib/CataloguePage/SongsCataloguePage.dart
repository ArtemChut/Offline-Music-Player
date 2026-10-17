import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../SettingsPage.dart';
import '../StatisticsPage.dart';

import '../sideFiles/loadNotifiers.dart';
import '../sideFiles/savingPrefs.dart';
import '../sideFiles/bottomNavBar.dart';

import 'songInteraction.dart';
import 'songCards.dart';

import '../consts/notifiers.dart';
import '../consts/styles.dart';



/* ------------------------------
       ALL THE VARIABLES
-------------------------------*/
int songsCount = 0;

int? currentSongIndex;

final double albumCoverSize = 240.0; // 300px is the width of every card so we give it a little margin
final double cardWidth = 300;

// colours of the cards for light and dark modes
Color? cardColour;
Color? selectedCardColour;
Color? cardBackgroundColour;
void loadColours(){
  if (isLightModeNotifier.value){
    cardColour = Colors.white;
    selectedCardColour = Colors.white70;
    cardBackgroundColour = const Color.fromARGB(255, 244, 244, 244);
  }
  else{
    cardColour = const Color.fromARGB(13, 0, 0, 0);
    selectedCardColour = Colors.black;
    cardBackgroundColour = Colors.black26;
  }
}

// ALLOWS TO PLAY MUSIC FILES
final AudioPlayer audioPlayer = AudioPlayer();


class SongsCataloguePage extends StatefulWidget {
  const SongsCataloguePage({super.key});

  @override
  State<SongsCataloguePage> createState() => _SongsCatalogueState();
}

class _SongsCatalogueState extends State<SongsCataloguePage> {
  final ScrollController _scrollController = ScrollController();


  
  @override
  void initState() {
    super.initState();

    initLoadData();
  }

  Future<void> initLoadData() async {
    await initLoadSongsList();
    songsCount = loadedSongsNotifier.value.length;

    await initLoadCurrSong();
    currentSongIndex = currentSongNotifier.value;

    await initLoadTimePlayed();
    if (currentSongIndex != null){
      final timePlayed = timePlayedNotifier.value;

      try{
        await audioPlayer.setFilePath(loadedSongsNotifier.value[currentSongIndex!].path); // loading the song using its path

        if (timePlayed != null){
          await audioPlayer.seek(Duration(milliseconds: timePlayed));
        }
      }
      on PlayerInterruptedException{
        // if user interacts with a song before everything had enough time to be initialised - don't do anything
      }
    }
    
  }



  @override
  void dispose() {
    _scrollController.dispose();

    audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;



    return ValueListenableBuilder(
      valueListenable: isLightModeNotifier,
      builder: (context, isLightMode, child) {
        loadColours(); // changes colour of cards if the theme colour changes
        // APPBAR
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
        
            backgroundColor: !isLightMode ? const Color.fromARGB(255, 37, 31, 48) : const Color.fromARGB(255, 118, 226, 174),

            // EVRYTHING INSIDE THE APPBAR
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // button allowing to change the theme colour
                IconButton(
                  style: IconButtonStyles.iconButton,
                  onPressed: () async {
                    isLightModeNotifier.value = !isLightModeNotifier.value;
                    saveThemeColour();
                  },
                icon: Icon(isLightMode ? Icons.light_mode : Icons.dark_mode),
                ),

                // pulling up the stats button
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: !isLightMode ? const Color.fromARGB(255, 44, 37, 56) : const Color.fromARGB(255, 151, 224, 189),
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: IconButton(
                    style: IconButtonStyles.iconButton,
                    hoverColor: Colors.transparent,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const StatisticsPage();
                      },));
                    },
                    icon: Icon(Icons.add_chart_rounded)
                  )
                ),

                IconButton(
                  style: IconButtonStyles.iconButton,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return const SettingsPage();
                    },));
                  },
                  icon: Icon(Icons.settings)
                )
              ],  
            ),
          ),




          // MAIN BODY
          body: Padding(padding: EdgeInsetsGeometry.symmetric(
            vertical: screenHeight/23,
            horizontal: screenWidth/20
          ),


            child: Center(
              // EVRYTHING INSIDE THE PAGE
              child: Container(
                width: double.maxFinite,
                height: screenHeight - (screenHeight/23*2)-114, // thingy in the brackets is how big the padding is, 114 is the height of a bottom nav bar
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth*0.06,
                  vertical: screenHeight*0.05
                ),
                decoration: BoxDecoration(
                  color: cardBackgroundColour,
                  borderRadius: BorderRadius.circular(20) 
                ),
                
                child: ValueListenableBuilder(
                  valueListenable: loadedSongsNotifier, builder: (context, listOfSongs, child) {
                    
                    if (listOfSongs.isEmpty){
                      return Center(child: Text("nooooo, add some songs!!"));
                    }

                    return Listener(
                        onPointerSignal: (event) {
                          if (event is PointerScrollEvent && _scrollController.hasClients){
                            _scrollController.jumpTo((_scrollController.offset + (event.scrollDelta.dy > 0 ? cardWidth : -cardWidth))
                              .clamp(
                                0.0,
                                _scrollController.position.maxScrollExtent,
                              ),
                            );
                          }
                        },

                        // the cards themself
                        child: ListView.builder(
                          itemCount: listOfSongs.length,
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          itemBuilder: (context, index) {

                            final currSongIndexReversed = songsCount-1-index; // we add songs right to left, so we reverse the i
                        
                            final song = listOfSongs[currSongIndexReversed];

                          
                            return GestureDetector(
                              onTap: () async {
                                await changeSong(index, loadedSongsNotifier); // changing the song currently playing
                                setState(() {
                                  // mb, ik it looks stupid but otherwise the update (new currently selected song) isnt being properly displayed
                                  currentSongIndex = currentSongIndex;
                                });
                              },
          
                              child: SizedBox(
                                width: cardWidth,
                                child: Card(
                                  color: index == currentSongIndex ? selectedCardColour : cardColour,

                                  child: Padding(
                                    padding: EdgeInsetsGeometry.symmetric(
                                      vertical: 12,
                                      horizontal: cardWidth*0.05
                                    ),
                                    
                                    // if a song is currently chosen - display extra stats
                                    child:
                                    index == currentSongIndex ? 
                                    // a song thats currently delected, has skip/pause buttons and more
                                    SongCard(
                                      albumCoverSize: albumCoverSize,
                                      cardColour: cardColour,
                                      cardWidth: cardWidth,
                                      currentSongIndex: currentSongIndex,
                                      index: index,
                                      screenHeight: screenHeight,
                                      selectedCardColour: selectedCardColour,
                                      song: song,
                                      currentSong: true
                                    ) :
                                    // a normal song card (not currently playing) + only shows song's name, artist, album cover
                                    SongCard(
                                      albumCoverSize: albumCoverSize,
                                      cardColour: cardColour,
                                      cardWidth: cardWidth,
                                      currentSongIndex: currentSongIndex,
                                      index: index,
                                      screenHeight: screenHeight,
                                      selectedCardColour: selectedCardColour,
                                      song: song,
                                      currentSong: false
                                    )
                                  ),
                                ),
                              ),
                            );
                        },),
                    );
                  },
                ),
              ),
          ),
        ),



        // BOTTOM NAV BAR TO TRANSFER BETWEEN PAGES
        bottomNavigationBar: BottomNavBar(
          currentIndex: 0
        )
      );
      },
    );
  }
}