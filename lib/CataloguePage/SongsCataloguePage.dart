import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/sideFiles/changingSongProps.dart';

import '../sideFiles/loadNotifiers.dart';
import '../sideFiles/savingPrefs.dart';
import 'sideFiled/songInteraction.dart';

import '../consts/notifiers.dart';
import '../consts/styles.dart';

import 'sideFiled/songCards.dart';

import '../SettingsPage.dart';




/* ------------------------------
       ALL THE VARIABLES
-------------------------------*/

List<int> selectedSongs = []; // saves indexes of all songs that are selected
bool selecting = false; // whether a user is selecting multiple songs or not


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

// ALLOWS TO SCROLL THROUGH THE SONGS CAROUSEL
ScrollController scrollController = ScrollController();


class SongsCataloguePage extends StatefulWidget {
  const SongsCataloguePage({super.key});

  @override
  State<SongsCataloguePage> createState() => _SongsCatalogueState();
}

class _SongsCatalogueState extends State<SongsCataloguePage> {
  
  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      scrollBarPosNotifier.value = scrollController.offset;
      saveScrollBarPos(scrollController.offset);
    });

    initLoadData(); // initialise all data (notifiers)
  }

  Future<void> initLoadData() async {
    await initLoadSongsList();
    songsCount = loadedSongsNotifier.value.length;

    await initLoadCurrSong();
    currentSongIndex = currentSongNotifier.value;

    await restoreScrollPosition();


    if (currentSongIndex != null){


      try{
        await audioPlayer.setFilePath(loadedSongsNotifier.value[songsCount - 1 - currentSongIndex!].path); // loading the song using its path

        await initLoadTimePlayed(); // loading a time where a song was left of
        final timePlayed = timePlayedNotifier.value;
        await audioPlayer.seek(Duration(milliseconds: timePlayed));
      }
      on PlayerInterruptedException{
        // if user interacts with a song before everything had enough time to be initialised - don't do anything
      }
    }
  }



  @override
  void dispose() {
    scrollController.dispose();

    audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;



    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape){
          setState(() {
            selecting = false;
            selectedSongs.clear();
          });
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap:() {
          setState(() {
            selecting = false;
            selectedSongs.clear();
          });
        },
        child: ValueListenableBuilder(
          valueListenable: isLightModeNotifier,
          builder: (context, isLightMode, child) {
            loadColours(); // changes colour of cards if the theme colour changes
            // APPBAR
            return Scaffold(
              appBar: customAppBar(
                elements: [
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
                ]
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
                          return Center(child: Text("nooooo, your song catalogue is empty, add some songs!!"));
                        }
        
                        return Listener(
                            onPointerSignal: (event) {
                              if (event is PointerScrollEvent && scrollController.hasClients){
                                scrollController.jumpTo((scrollController.offset + (event.scrollDelta.dy > 0 ? cardWidth/2 : -cardWidth/2))
                                  .clamp(
                                    0.0,
                                    scrollController.position.maxScrollExtent,
                                  ),
                                );
                              }
                            },
        
                            // the cards themself
                            child: ListView.builder(
                              itemCount: listOfSongs.length,
                              scrollDirection: Axis.horizontal,
                              controller: scrollController,
                              itemBuilder: (context, index) {
        
                                final currSongIndexReversed = songsCount-1-index; // we add songs right to left, so we reverse the i
                            
                                final song = listOfSongs[currSongIndexReversed];
        
                              
                                return GestureDetector(
                                    // single left mouse click
                                    onTap: () async {
                                      await changeSong(index, loadedSongsNotifier); // changing the song currently playing
                                      setState(() {
                                        // mb, ik it looks stupid but otherwise the update (new currently selected song) isnt being properly displayed
                                        currentSongIndex = currentSongIndex;
                                      });
                                    },
                                  
                                    // right mouse click
                                    onSecondaryTapUp: (details) async {
                                      // get the position of the mouse
                                      final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                                  
                                      final mousePosition = overlay.globalToLocal(details.globalPosition);
                                  
                                      // show the popup menu at the mouse position
                                      final action = await showMenu<String>(
                                        context: context,
                                        position: RelativeRect.fromLTRB(
                                          mousePosition.dx,
                                          mousePosition.dy,
                                          overlay.size.width - mousePosition.dx,
                                          overlay.size.height - mousePosition.dy,
                                        ),
                                        items: [
                                          // change song's name button
                                          const PopupMenuItem(
                                            value: 'name',
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text("Change song's name"),
                                                Icon(Icons.abc_rounded)
                                              ],
                                            ),
                                          ),
                                  
                                          // change name of the artist button
                                          const PopupMenuItem(
                                            value: 'artist',
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text("Change song's artist name"),
                                                Icon(Icons.person_3_outlined)
                                              ],
                                            ),
                                          ),
                                  
                                          // change the album cover button
                                          const PopupMenuItem(
                                            value: 'albumCover',
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text('Change the album cover'),
                                                Icon(Icons.album)
                                              ],
                                            ),
                                          ),
        
                                          // allows to select multiple songs
                                          const PopupMenuItem(
                                            value: 'select',
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text('Select multiple songs'),
                                                Icon(Icons.add_circle_outline)
                                              ],
                                            ),
                                          ),
                                  
                                          // delete a song button
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text('Delete song'),
                                                Icon(Icons.delete, color: Colors.red)
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                  
                                      // handles the selected action
                                      switch (action) {
                                        case "delete":
                                        if (selecting){
                                          for (int index in selectedSongs){
                                            deleteSong(loadedSongsNotifier.value[index], songsCount-currSongIndexReversed-1);
                                          }
                                        }
                                          deleteSong(song, songsCount-currSongIndexReversed-1);
                                        case "name":
                                          changeSongProps("name", song, context, setState);
                                        case "artist":
                                          changeSongProps("artist", song, context, setState);
                                        case "albumCover":
                                          changeAlbumCover(song, setState);
                                        case "select":
                                          setState(() {
                                            selecting = true;
                                          });
                                      }
                                    },
                                  
                                  
                                            
                                    child: SizedBox(
                                      width: cardWidth,
                                      child: Card(
                                        color: index == currentSongIndex ? selectedCardColour : cardColour,
                                  
                                        child: Stack(
                                          children: [
                                          // allows to select multiple songs
                                          if (selecting)
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  // remove from a list of selected songs if the song has already been selected
                                                  if (selectedSongs.contains(index)) {
                                                    selectedSongs.removeAt(index);
                                                  }
                                                  // add to a list of selected songs if it's not inside the list yet
                                                  else {
                                                    selectedSongs.add(index);
                                                  }
                                                });
                                              },
                                              icon: Icon(
                                                selectedSongs.contains(index)
                                                    ? Icons.check_circle // if selected
                                                    : Icons.circle_outlined, // if not selected
                                                size: screenHeight*0.8*0.05
                                              ),
                                            ),
        
                                            Padding(
                                            padding: EdgeInsetsGeometry.symmetric(
                                              vertical: 12,
                                              horizontal: cardWidth*0.05
                                            ),
                                            
                                            child:
                                              // if a song is a song currently playing
                                              index == currentSongIndex
                                              ? SongCard(
                                                  setState,
                                                  albumCoverSize: albumCoverSize,
                                                  cardColour: cardColour,
                                                  cardWidth: cardWidth,
                                                  currentSongIndex: currentSongIndex,
                                                  index: index,
                                                  screenHeight: screenHeight,
                                                  selectedCardColour: selectedCardColour,
                                                  song: song,
                                                  currentSong: true,
                                                )
                                              // if a song is a song not currently playing
                                              : SongCard(
                                                  setState,
                                                  albumCoverSize: albumCoverSize,
                                                  cardColour: cardColour,
                                                  cardWidth: cardWidth,
                                                  currentSongIndex: currentSongIndex,
                                                  index: index,
                                                  screenHeight: screenHeight,
                                                  selectedCardColour: selectedCardColour,
                                                  song: song,
                                                  currentSong: false,
                                                ),
                                          ),]
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
        ),
      ),
    );
  }
}