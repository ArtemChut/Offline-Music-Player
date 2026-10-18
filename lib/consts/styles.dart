import 'package:flutter/material.dart';

import 'package:music_player/consts/notifiers.dart';
import 'package:music_player/sideFiles/savingPrefs.dart';

import '../StatisticsPage.dart';
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StatisticsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_chart_rounded),
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
