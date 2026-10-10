import 'package:flutter/material.dart';
import 'sideFiles/bottomNavBar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      appBar: AppBar(
        // ALLOWS TO GO BACK TO THE PREVIOUS PAGE
      ),



      body: Padding(padding: EdgeInsetsGeometry.symmetric(
        vertical: screenHeight/23,
        horizontal: screenWidth/20),

        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.red,
        ),
      ),


      // BOTTOM NAV BAR TO TRANSFER BETWEEN PAGES
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2
      )
    );
  }
}