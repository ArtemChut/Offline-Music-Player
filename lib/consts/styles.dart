import 'package:flutter/material.dart';

const double nameSize = 26;
const double artistSize = 20;

class IconButtonStyles {
  static final iconButton = IconButton.styleFrom(enabledMouseCursor: SystemMouseCursors.click);

  static IconButton trasnferIconButton ({action, icon}) {
    return IconButton(
      style: iconButton,
      onPressed: () { action(); },

    icon: icon);
  } 
}

class Texts {
  static Text simpleSizedText ({String? text, double? fontSize, String? font}) {
    return Text(
      text!,
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: font
      ),
    );
  }
}
