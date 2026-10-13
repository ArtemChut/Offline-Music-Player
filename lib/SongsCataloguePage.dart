import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_player/sideFiles/consts/notifiers.dart';
import 'sideFiles/savingPrefs.dart';
import 'sideFiles/bottomNavBar.dart';
import 'SettingsPage.dart';
import 'StatisticsPage.dart';
import 'sideFiles/consts/styles.dart';
import 'sideFiles/loadNotifiers.dart';

class SongsCataloguePage extends StatefulWidget {
  const SongsCataloguePage({super.key});

  @override
  State<SongsCataloguePage> createState() => _SongsCatalogueState();
}

class _SongsCatalogueState extends State<SongsCataloguePage> {
  final ScrollController _scrollController = ScrollController();

  final double albumCoverSize = 240.0; // 300px is the width of every card so we give it a little margin
  final double cardWidth = 300;

  int? currentSongIndex;
  

  @override
  void initState() {
    super.initState();
    initLoadData();
  }

  Future<void> initLoadData() async {
    await initLoadSongsList();
    await initLoadCurrSong();
    if (currentSongNotifier.value == null) {print(loadedSongsNotifier.value[currentSongIndex!]);}

    currentSongIndex = currentSongNotifier.value;
  }



  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

            // EVRYTHING INSIDE THE APPBAR
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // button allowing to change the theme colour
                IconButton(
                  style: AppButtonStyles.iconButton,
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
                    style: AppButtonStyles.iconButton,
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
                  style: AppButtonStyles.iconButton,
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
                  color: Colors.red,
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

                        
                          final song = listOfSongs[index];

                        
                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                if (currentSongIndex != null){
                                  loadedSongsNotifier.value[currentSongIndex!].isPlaying = false;
                                }
                                currentSongIndex = index;
                                loadedSongsNotifier.value[currentSongIndex!].isPlaying = true;

                              });
                              await saveCurrSong(index);
                            },
        
                            child: SizedBox(
                              width: cardWidth,
                              child: Card(
                                color: index == currentSongIndex ? Colors.deepOrange : Colors.lightGreenAccent,

                                child: Padding(
                                  padding: EdgeInsetsGeometry.symmetric(
                                    vertical: 12,
                                    horizontal: cardWidth*0.05
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                                    
                                    // ALBUM COVER
                                    if (song.cover == null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SvgPicture.asset("assets/images/heart.svg", width: albumCoverSize)
                                      )
                                    else
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(song.cover!, width: albumCoverSize)
                                      ),
                                                    
                                    // a little margin in between
                                    SizedBox(height: screenHeight*0.6*0.08),
                                    
                                    // NAME + ARTIST NAME
                                    Text(
                                      song.name,
                                                    
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: nameSize,
                                      ),
                                    ),
                                                    
                                    Text(
                                      song.artist,
                                                    
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: artistSize,
                                      ),
                                    ),
                                  ],)
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