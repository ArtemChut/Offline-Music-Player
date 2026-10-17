import 'package:flutter/material.dart';

const double nameSize = 26;
const double artistSize = 20;

class IconButtonStyles {
  static final iconButton = IconButton.styleFrom(enabledMouseCursor: SystemMouseCursors.click);

  static IconButton trasnferIconButton ({VoidCallback? action, Icon? icon}) {
    return IconButton(
      style: iconButton,
      onPressed: () { action!(); },

    icon: icon!);
  } 
}

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
