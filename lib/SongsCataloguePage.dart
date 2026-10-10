import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_player/sideFiles/consts/notifiers.dart';
import 'sideFiles/savingPrefs.dart';
import 'sideFiles/bottomNavBar.dart';
import 'SettingsPage.dart';
import 'StatisticsPage.dart';
import 'sideFiles/consts/styles.dart';
import 'sideFiles/importFiles.dart';

class SongsCataloguePage extends StatefulWidget {
  const SongsCataloguePage({super.key});

  @override
  State<SongsCataloguePage> createState() => _SongsCatalogueState();
}

class _SongsCatalogueState extends State<SongsCataloguePage> {

  @override
  void initState() {
    super.initState();
    initLoadNotifier();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final albumCoverSize = screenWidth*0.2*0.95;


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

                    return ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false), // removing a scrollbar thingy on the side

                      child: ListView.builder(
                        itemCount: listOfSongs.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {

                        final song = listOfSongs[index];
                      
                        return SizedBox(
                          width: screenWidth*0.25,
                          child: Card(
                            child: Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                vertical: screenHeight*0.01,
                                horizontal: screenWidth*0.01
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [

                                // ALBUM COVER
                                song.cover == null ? SvgPicture.asset("assets/images/heart.svg", width: albumCoverSize) : Image.memory(song.cover!, width: albumCoverSize),
                                
                                // NAME + ARTIST NAME
                                Column(children: [
                                  Text(song.name),
                                  Text(song.artist)
                                ],)
                              ],),
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