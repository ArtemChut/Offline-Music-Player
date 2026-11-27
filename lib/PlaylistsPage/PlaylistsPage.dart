import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_player/CataloguePage/SongsCataloguePage.dart';

import 'package:music_player/CataloguePage/sideFiled/songInteraction.dart';
import 'package:music_player/PlaylistsPage/playlistInteractions.dart';
import 'package:music_player/sideFiles/changingSongProps.dart';

import '../../sideFiles/savingPrefs.dart';

import '../../consts/notifiers.dart';
import '../../consts/styles.dart';

import 'playlistCards.dart';

import '../../SettingsPage.dart';



/* ------------------------------
       ALL THE VARIABLES
-------------------------------*/

// allows users to create playlists (positions the card in the middle of the screen)
final GlobalKey boardKey = GlobalKey();
bool creatingPlaylist = false;

List<int> selectedPlaylists = []; // saves indexes of all songs that are selected
bool selecting = false; // whether a user is selecting multiple songs or not

int playlistsCount = 0;


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





class PlaylistsPage extends StatefulWidget {
  final bool addingTo; 
  final List<int> songs;
  const PlaylistsPage({super.key, required this.addingTo, required this.songs});

  @override
  State<PlaylistsPage> createState() => _PlatlistsPage();
}

class _PlatlistsPage extends State<PlaylistsPage> {
  // ALLOWS TO SCROLL THROUGH THE SONGS CAROUSEL
  ScrollController scrollController = ScrollController(); 

  
  @override
  void initState() {
    super.initState();

    // ALLOWS TO SCROLL THROUGH THE SONGS CAROUSEL
    ScrollController scrollController = ScrollController();

    scrollController.addListener(() {
      scrollBarPosNotifier.value = scrollController.offset;
      saveScrollBarPos(scrollController.offset);
    });

    initLoadData(); // initialise all data (notifiers)
  }

  Future<void> initLoadData() async {
    await restoreScrollPosition(scrollController);
  }



  @override
  void dispose() {
    scrollController.dispose();

    creatingPlaylist = false;

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
            selectedPlaylists.clear();

            creatingPlaylist = false;
          });
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap:() {
          setState(() {
            selecting = false;
            selectedPlaylists.clear();
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
                      setState(() {
                        creatingPlaylist = true;
                      });
                  },
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset("assets/images/highlight.svg", width: screenWidth*0.07,),

                      Transform.scale(
                      child: Icon(Icons.create_new_folder_outlined),
                      scale: 2,
                    ),
                  ])
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
                    
                    child: Stack(
                      children: [
                        if (creatingPlaylist)
                          createPlaylist(
                            screenWidth,
                            cardColour,
                            cardBackgroundColour,
                            screenHeight,
                            setState,
                            context                        
                          )
                          
                        else
                          ValueListenableBuilder(
                          valueListenable: allPlaylistsNotifier, builder: (context, listOfPlaylists, child) {
                            
                            if (listOfPlaylists.isEmpty){
                              return Center(
                                child: Text("nooooo, you don't have any playlists. add some right now!!")
                              );
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
                                itemCount: listOfPlaylists.length,
                                scrollDirection: Axis.horizontal,
                                controller: scrollController,
                                itemBuilder: (context, index) {
                              
                                  final currPlaylistReversed = playlistsCount-1-index; // we add songs right to left, so we reverse the i
                              
                                  final playlist = listOfPlaylists[currPlaylistReversed];
                              
                                
                                  return GestureDetector(
                                      // single left mouse click
                                      onTap:() {
                                        if (widget.addingTo) {
                                          playlist.songsInside?.addAll(widget.songs);
                      
                                          allPlaylistsNotifier.value = [
                                            ...allPlaylistsNotifier.value
                                          ];
                                        }
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SongsCataloguePage(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                      
                                      //OPEN THAT PLAYLIST
                                    
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
                                          
                                          // DISPLAYING THE POP UPS LIST THAT ALLOW TO MODIFY PROPERTIES OF A SONG
                                          items: [
                                            ...popUps(selecting)
                                          ]
                                        );
                                    
                                        // handles the selected action
                                        switch (action) {
                                          case "delete":
                                            // if selecting multiple songs
                                            if (selecting){
                                              selectedPlaylists.sort((a, b) => b.compareTo(a)); // sort the list from largest index to smallest in order not to get an our of range error
                      
                                              // removing each song one by one
                                              for (int playlist_index in selectedPlaylists){
                                                deleteSong(loadedSongsNotifier.value[loadedSongsNotifier.value.length-1-playlist_index], loadedSongsNotifier.value.length-1-playlist_index);
                                              }
                                              setState(() {
                                                selecting = false;
                                                selectedPlaylists.clear();
                                              });
                                            }
                                            // if deleting a single song
                                            else{
                                              deleteSong(playlist, index);
                                            }
                                          case "name":
                                            changeSongProps("name", playlist, context, setState);
                                          case "albumCover":
                                            changeAlbumCover(playlist, setState);
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
                                            // allows to select multiple playlists
                                            if (selecting)
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    // remove from a list of selected playlists if the playlist has already been selected
                                                    if (selectedPlaylists.contains(index)) {
                                                      selectedPlaylists.remove(index);
                                                    }
                                                    // add to a list of selected playlists if it's not inside the list yet
                                                    else {
                                                      selectedPlaylists.add(index);
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                  selectedPlaylists.contains(index)
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
                                              ? PlaylistCard(
                                                  setState,
                                                  albumCoverSize: albumCoverSize,
                                                  cardColour: cardColour,
                                                  cardWidth: cardWidth,
                                                  screenHeight: screenHeight,
                                                  selectedCardColour: selectedCardColour,
                                                  playlist: playlist,
                                                )
                                              // if a song is a song not currently playing
                                              : PlaylistCard(
                                                  setState,
                                                  albumCoverSize: albumCoverSize,
                                                  cardColour: cardColour,
                                                  cardWidth: cardWidth,
                                                  screenHeight: screenHeight,
                                                  selectedCardColour: selectedCardColour,
                                                  playlist: playlist,
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
                        ]
                      ),
                    ),
                ),
              ),
          
          
          
              // BOTTOM NAV BAR TO TRANSFER BETWEEN PAGES
              bottomNavigationBar: BottomNavBar(
                currentIndex: 2
              )
            );
            },
          ),
      ),
    );
  }
}